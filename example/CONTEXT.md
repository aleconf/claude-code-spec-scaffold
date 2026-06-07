# Trim

Trim is a URL shortening and click analytics service. It maps memorable short
codes to destination URLs, records each redirect, and aggregates redirects
into reports for the marketing team.

## Language

**Short link**:
A persistent mapping from a short code (e.g. `trim.co/spring-sale`) to a
destination URL. Owned by the marketer who created it. Has a lifecycle:
active, paused, or archived.
_Avoid_: URL (ambiguous — destination or short?), tinyurl, slug
(the slug is the short code, not the whole link)

**Destination URL**:
The long URL that a short link redirects to. Always belongs to exactly one
short link at any given time; changing it creates a new revision but does
not create a new short link.
_Avoid_: Target, long URL, real URL

**Click event**:
An immutable record of one visitor following one short link at one moment
in time. Captured at redirect time and written asynchronously to ClickHouse.
Never updated, never deleted (except by GDPR erasure).
_Avoid_: Hit, visit, view, request, redirect (the redirect is the action;
the click event is the record of it)

**Campaign**:
A user-defined tag grouping multiple short links for joint reporting (e.g.
"2026-spring-launch" might tag 12 short links across email and social).
A short link belongs to zero or one campaign. Campaigns have no lifecycle
of their own — they exist as long as at least one short link references them.
_Avoid_: Project, group, folder

## Relationships

- A **short link** has exactly one **destination URL** (current revision)
- A **short link** belongs to zero or one **campaign**
- A **click event** references exactly one **short link** (by short code,
  not by internal ID — the short code is the stable public identifier)
- A **campaign** is a tag, not an entity that owns short links — deleting a
  campaign tag does not delete its short links

## Flagged ambiguities

**"Link" alone is ambiguous** — it can mean a short link (our domain object)
or a hyperlink on a webpage (web concept). In code and docs, always say
"short link" unless context makes it unmistakable.

**"Visitor" is not a domain term.** We don't model visitors as entities
because we don't track identity across click events (no cookies, no
fingerprinting — GDPR). When you need to refer to "the person who clicked,"
say so in prose; don't reify it as a Visitor object.

## Example dialogue

> **Marketer:** "Can we see how many people visited the spring sale page?"
>
> **Dev:** "We can count click events for the short links tagged with the
> `spring-sale` campaign. We can't tell you how many *people* — we don't
> track identity — but we can tell you how many redirects happened, broken
> down by country and referrer."
>
> **Marketer:** "Fine. And if I change the destination URL on one of those
> short links mid-campaign, do the old click events still count?"
>
> **Dev:** "Yes. Click events reference the short link by short code, not
> by destination URL. The destination revision history is separate. Your
> click count is continuous across the change."
