# Plan: Campaign tagging for short links

**Status:** Approved post-grill, ready for implementation
**Author:** @marco (with Claude)
**Grilled:** 2026-05-28

## Goal

Let marketers tag a short link with a campaign name at creation or edit
time, and let them filter the dashboard by campaign.

## Scope

In scope:
- A `campaign` text field on the short link create/edit form (free-form,
  trimmed, lowercased, max 64 chars)
- A campaign filter dropdown on the dashboard listing all distinct
  non-empty campaign values
- Filtering the click-events query by campaign (via the short links it
  tags)

Out of scope:
- Campaign-level CRUD (no campaign entity — see CONTEXT.md, campaigns are
  tags, not entities)
- Campaign analytics aggregated independently of short links
- Campaign permissions or ownership
- Renaming a campaign (do it with a SQL `UPDATE` for now; revisit if
  marketers ask for UI support)

## Approach

1. **Schema.** Add a `campaign` column to `short_links` (`text`, nullable,
   indexed). No new table.
   → verify: migration runs cleanly on a copy of prod; existing rows have
   `NULL` campaign.

2. **API.** Extend `POST /links` and `PATCH /links/:code` to accept an
   optional `campaign` string. Normalize (trim, lowercase, reject if
   >64 chars).
   → verify: contract tests cover empty, valid, oversized, mixed-case
   inputs.

3. **Dashboard filter.** Add a "Campaign" dropdown above the link list,
   populated from `SELECT DISTINCT campaign FROM short_links WHERE
   campaign IS NOT NULL ORDER BY campaign`. Selecting one filters the
   list and the chart.
   → verify: with 3 seeded campaigns and 1 unclassified link, the
   dropdown shows 3 options + "All"; filtering shows the right links.

4. **Click-event filtering.** The dashboard's ClickHouse query joins
   click events to short links by short code, then filters by campaign.
   → verify: a click on a campaign-tagged link appears under that
   campaign's filter; a click on an unclassified link only appears
   under "All".

## Non-decisions (deliberately deferred)

- **Autocomplete on the campaign field.** Discussed in grill; deferred
  until we have >20 distinct campaigns in prod. Free text is fine for now.
- **Validation against a campaign allowlist.** Discussed; rejected.
  Marketers are trusted SSO users; allowlist adds friction without
  preventing real problems.

## Open questions resolved during grill

- *Q: Should "campaign" be on the click event too, denormalized for
  fast filtering?*
  A: No. Click events reference short links by short code; we join.
  Denormalizing means historical click events lock in the campaign at
  click time, but our CONTEXT.md says campaign tags can be changed
  retroactively. Joining is the consistent answer.
  (Possible ADR if perf becomes a problem — not yet.)

- *Q: What happens to old click events when a short link's campaign
  changes?*
  A: They re-attribute to the new campaign on next query. This is the
  intended behavior given the join model. Documented in CONTEXT.md
  example dialogue.

- *Q: Empty string vs NULL for "no campaign"?*
  A: NULL. The API normalizes empty/whitespace-only input to NULL
  before persisting.

## Success criteria

- A marketer can tag a new or existing short link with a campaign in
  the UI.
- The dashboard filter dropdown lists all distinct campaigns and
  filters both the link list and the click chart.
- All four verification steps above pass on a staging environment with
  seeded data.
- No regression in redirect p99 latency (still <50ms; campaign field
  is not touched on the redirect path).
