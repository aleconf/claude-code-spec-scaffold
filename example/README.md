# Worked example: Trim

A filled-in version of the template for a fictional URL shortener called
**Trim**, used internally by a marketing team.

This folder demonstrates the steady state — what your repo should look
like after a few weeks of using the template, not at day zero.

## Files

| File | What it shows |
|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | The `## Project Overview` section filled in with real constraints, users, stack, and a pointer to `CONTEXT.md` |
| [`CONTEXT.md`](./CONTEXT.md) | Four real domain terms with their aliases-to-avoid, a relationships block, a flagged ambiguity, and an example dialogue between a dev and a marketer |
| [`docs/adr/0001-ip-hashing-at-ingest.md`](./docs/adr/0001-ip-hashing-at-ingest.md) | An ADR that passes all three criteria (hard to reverse, surprising without context, real trade-off) |
| [`docs/plan-campaign-tagging-2026-05-28.md`](./docs/plan-campaign-tagging-2026-05-28.md) | A post-grilling plan doc, showing in-scope/out-of-scope, verifiable steps, deferred non-decisions, and resolved open questions |

## How to read these

If you're new to the template, skim them in this order:

1. **`CLAUDE.md`** — to see what "filled in" looks like
2. **`CONTEXT.md`** — to see what the glossary discipline produces
3. **The plan doc** — to see what a grilling session crystallizes into
4. **The ADR** — to see what *does* warrant an ADR vs what doesn't

Notice what's **not** here:

- No ADR for "we chose Postgres" (not surprising — boring default)
- No ADR for "we use SSO" (not a real trade-off — it's company policy)
- No glossary entry for "timeout" or "retry" (general programming
  concepts, not domain language)
- No campaign entity in CONTEXT.md — campaigns are tags, and the
  glossary says so explicitly

These omissions are the point. The template biases toward writing less,
not more.
