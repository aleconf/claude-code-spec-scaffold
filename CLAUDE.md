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

<!-- Describe: what this repo does, its main constraints, who uses it -->
