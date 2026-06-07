# CLAUDE.md

This file is read automatically by Claude Code in every session.
All instructions are mandatory and apply to every contributor.

## Coding Guidelines

For all coding tasks — including plan mode, implementation, review,
refactoring, and debugging — **always invoke the `karpathy-guidelines` skill
via the Skill tool before writing or editing any code.**
If in doubt, enhance code clarity, consistency, and maintainability.

## Planning Sessions

Whenever a plan is being presented, **always invoke the `grill-with-docs` skill
via the Skill tool** to stress-test it before finalising.

## Plan Mode Rules

**Always save the implementation plan as a Markdown file in `docs/` before exiting plan mode.**

- Create `docs/` if it does not already exist (`mkdir -p docs/`)
- Filename: `docs/plan-<feature-name>-<YYYY-MM-DD>.md`
- Create the file **before** calling ExitPlanMode
- Do not proceed to implementation until the file is confirmed saved

## Project Overview

**Trim** is a self-hosted URL shortener with click analytics, used internally
by our marketing team to track campaign performance across email, social, and
print channels.

### What it does

- Marketers create **short links** that redirect to long destination URLs
- Each redirect is recorded as a **click event** with referrer, user agent, and
  approximate geolocation (country-level, from IP)
- A dashboard aggregates click events into per-link and per-campaign reports

### Main constraints

- **Self-hosted, single-region.** Runs on one VM in our Frankfurt DC. No
  multi-region replication. Acceptable downtime: 1h/month.
- **GDPR scope.** Click events contain IP-derived data. IPs are hashed at
  ingest and never stored raw. See `docs/adr/0001-ip-hashing-at-ingest.md`.
- **Redirect latency budget: 50ms p99.** Anything slower and marketers notice
  on mobile. The redirect path must not touch the analytics database
  synchronously.
- **No public sign-up.** Auth is via the company SSO; only marketing-team
  members can create short links.

### Who uses it

- **Marketers** create and manage short links, read dashboards.
- **Engineering** maintains the service and consumes the click event stream
  for ad-hoc analysis.
- **Visitors** (external) hit short links and get redirected. They never see
  the Trim UI.

### Stack

- Go for the redirect service (single binary, low-latency path)
- Postgres for the link catalog
- ClickHouse for click events (append-only, columnar reads for dashboards)
- A small Next.js dashboard for marketers

### Domain language

See [CONTEXT.md](./CONTEXT.md) for the canonical glossary. **Use the terms
defined there.** If you find yourself reaching for a synonym (e.g. "URL"
instead of "destination URL", "hit" instead of "click event"), stop and
check the glossary first.
