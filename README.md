# Claude Code Spec Scaffold

> Opinionated scaffolding for spec-driven AI coding — so your sessions leave behind **artefacts, not scrollback**.

<!--- ![Built for Claude Code](https://img.shields.io/badge/built%20for-Claude%20Code-d97757) -->
<!--- ![License: MIT](https://img.shields.io/badge/license-MIT-blue) -->

![Built for Claude Code](/assets/built_for-Claude%20Code-d97757.svg)
![License: MIT](/assets/license-MIT-blue.svg)

A GitHub template that wires [Claude Code](https://github.com/anthropics/claude-code) skills, a plan-doc hook, and a worked example into one spec-driven workflow. After a few minutes of configuration, your very first planning session produces a written, reviewable plan instead of a chat log you will never reopen.

## The problem this solves

Claude Code is powerful and easy to use even without structure. But *without* structure, sessions sprawl: plans drift, decisions get lost, the same questions get re-litigated next week, and the codebase fills with speculative abstractions nobody asked for.

This template enforces three disciplines that stop that drift — and once they are habitual, they cost you nothing:

| Discipline | What it gives you                                                                                                                                             |
|---|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Plans get grilled before they get built** | Claude interviews you against your project's glossary and prior decisions, surfacing ambiguity and contradictions *before* a line of code exists.             |
| **Code stays small and surgical** | Karpathy-style guidelines bias Claude toward minimum-viable changes and explicit assumptions — no speculative abstractions, no "while I'm in here" refactors. |
| **Plans get written down, automatically** | A pre-tool hook refuses to let Claude leave plan mode until a dated plan doc is saved to `docs/`. The plan becomes an artefact, not a memory.                 |

## Contents

- [What a session looks like](#what-a-session-looks-like)
- [How enforcement works](#how-enforcement-works)
- [See it in steady state](#see-it-in-steady-state)
- [What is in the box](#what-is-in-the-box)
- [Quick start](#quick-start)
- [When this is not the right template](#when-this-is-not-the-right-template)
- [Customising](#customising)
- [Credits](#credits)

## What a session looks like

```text
You:    Let's plan the campaign tagging feature.

Claude: Before I propose anything — your CONTEXT.md says campaigns are
        tags, not entities. Is that still true? Because if so, "campaign
        CRUD" is not a thing we can build.

You:    Still true. Tags only.

Claude: Then question one: should the campaign field live on the click
        event too, denormalised for query speed?

        ...

Claude: Plan saved to docs/plan-campaign-tagging-2026-05-28.md.
        Ready to exit plan mode.
```

The glossary constrains the plan. The plan gets written down. The next session starts from artefacts, not memory.

## How enforcement works

The discipline is not a polite request buried in a prompt — it is wired into cooperating pieces that each do one job:

- **Skills** (`.claude/skills/`) carry the behaviour. `CLAUDE.md` points Claude at them every session, and Claude reads the relevant `SKILL.md` when its description matches the task. That is what triggers the grilling and the Karpathy-style restraint.
- **A reminder hook** keeps the skills front-of-mind. An `Edit|Write` `PreToolUse` hook (in `.claude/settings.json`) fires before any edit, nudging Claude to invoke `karpathy-guidelines` — and `grill-with-docs` first, during planning.
- **The hard-stop hook** (`.claude/hooks/require-plan-doc.sh`) is the rule that cannot be left to good intentions. It is an `ExitPlanMode` `PreToolUse` hook that exits non-zero — blocking the call — unless a *new* dated plan doc has landed in `docs/` since the last exit.
- **The example** (`example/`) shows the steady state, so you can see what "done right" looks like before you have produced it yourself.

The skills shape intent; the hooks enforce what intent alone will not.

## See it in steady state

The [`example/`](./example) directory contains **Trim**, a fictional URL shortener built with this template. Start with **[`example/README.md`](./example/README.md)** — it gives a guided reading order and, crucially, points out what is *deliberately missing* and why.

To see the payoff in one screen, read the dialogue at the bottom of [`example/CONTEXT.md`](./example/CONTEXT.md): a marketer asks "how many people visited the page?" and the glossary forces a precise answer — *we count click events, not people; we do not track identity.* That is a whole class of bad data model caught in a sentence, before it ever reached code.

The rest of the example is four files, each demonstrating one piece of the discipline:

1. [`example/CLAUDE.md`](./example/CLAUDE.md) — what a filled-in project overview looks like
2. [`example/CONTEXT.md`](./example/CONTEXT.md) — what the glossary discipline produces in practice
3. [`example/docs/plan-campaign-tagging-2026-05-28.md`](./example/docs/plan-campaign-tagging-2026-05-28.md) — what a post-grilling plan crystallises into
4. [`example/docs/adr/0001-ip-hashing-at-ingest.md`](./example/docs/adr/0001-ip-hashing-at-ingest.md) — what *does* warrant an ADR

Notice how short these files are. This is the point.

## What is in the box

```text
.
├── README.md                     # this file
├── CLAUDE.md                     # top-level instructions Claude reads every session
├── LICENSE
├── .gitignore
├── .claude/
│   ├── settings.json             # registers the hooks
│   ├── skills/                   # behaviours Claude reads
│   │   ├── grill-with-docs/      #   plan-grilling + glossary/ADR formats
│   │   └── karpathy-guidelines/  #   minimum-viable-change discipline
│   └── hooks/
│       └── require-plan-doc.sh   # blocks ExitPlanMode without a plan doc
└── example/                      # Trim — a worked example in steady state
    ├── README.md
    ├── CLAUDE.md
    ├── CONTEXT.md                # the glossary — fills in as you plan
    └── docs/
        ├── plan-campaign-tagging-2026-05-28.md
        └── adr/
            └── 0001-ip-hashing-at-ingest.md
```

## Quick start

### Prerequisites

- [Claude Code](https://github.com/anthropics/claude-code), installed and authenticated (a Claude Pro/Max subscription or Anthropic API access).
- A Unix-like shell with `bash` — the hooks are `.sh` scripts. On Windows, run inside [WSL](https://learn.microsoft.com/windows/wsl/) or Git Bash; the `chmod` step below will not work in `cmd`/PowerShell.
- [Git](https://git-scm.com/), and optionally the [GitHub CLI](https://cli.github.com) for the CLI path.

### 1. Create your project from this template

Pick whichever fits:

- **Web:** click the green **"Use this template"** button at the top of this repo's GitHub page, name your new repo, then `git clone` it locally.
- **CLI** (requires the GitHub CLI):
  ```bash
  gh repo create my-project --template <this-repo> && cd my-project
  ```

### 2. Finish setup and start planning

Fill in the "Project Overview" section in `CLAUDE.md`: see `example/CLAUDE.md` for inspiration.

```bash
# Make hooks executable (required)
chmod +x .claude/hooks/*.sh

# Open Claude Code and try a planning session
claude
> Plan a small first feature for me.
```

Claude will grill you against your `CONTEXT.md` (which may not exist yet at the start), save a plan doc to `docs/`, and refuse to exit plan mode until that file exists. The glossary fills itself in as you go — you do not need to write it upfront.

### Why a template and not just a `CLAUDE.md`?

Because the discipline depends on three things working together: the skills (which Claude reads), the hooks (which block bad exits and keep the skills in view), and the example (which shows the steady state). Assembling and tuning everything from scratch takes hours of fiddly setup. This template gives you the finished configuration, ready to use.

## When this is not the right template

- **Throwaway scripts and one-off prototypes.** The grilling and plan-doc overhead is meant for code that will be maintained. For 50-line spikes, skip it.
- **Solo experimentation over a single afternoon.** The discipline pays off when multiple people — or multiple sessions over time — touch the codebase. For a one-shot session, you do not need the scaffolding.
- **Projects without a real domain.** If the project is "wire library A to library B," there is no domain language to capture and `CONTEXT.md` will feel like make-work.

If you recognise yourself in one of these, you are better served by a leaner setup — and you can borrow the Karpathy guidelines on their own.

## Customising

The template has three extension points:

- **`.claude/skills/`** — Add or modify skills. Each is a folder with a `SKILL.md` Claude reads when the description matches. Drop in your own (testing conventions, deployment runbook, on-call protocol).
- **`.claude/hooks/`** — Add `PreToolUse` / `PostToolUse` hooks via `.claude/settings.json`. The bundled `require-plan-doc.sh` is the pattern: a short shell script that exits `0` to allow or non-zero to block.
  
  **How the plan-doc gate works.** The goal is one fresh plan per session: each new planning session's *first* `ExitPlanMode` should block, forcing Claude to write that session's plan before it can exit. The hook implements this by comparing modification times. It passes only when some `docs/plan-*-YYYY-MM-DD.md` file is **newer** than the `.claude/.last_plan_exit` marker, and on every pass it advances the marker to the current time, which re-arms the gate: once the marker is newer than every existing plan file, the next session's first exit is blocked until a genuinely new plan is saved with a newer timestamp. Note that the gate checks only whether *some* matching plan file is newer than the marker, so manually editing or touching an old plan doc will satisfy the next exit even if no new plan was written.
- **`CLAUDE.md`** — Top-level instructions Claude reads every session. Keep it short; link out to skills and `CONTEXT.md` rather than inlining detail.

## Credits

Built on:

- [Karpathy-Inspired Claude Code Guidelines](https://github.com/forrestchang/andrej-karpathy-skills) by Jiayuan Zhang — behavioural guidelines derived from Andrej Karpathy's observations on LLM coding pitfalls.
- [grill-with-docs](https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs) by Matt Pocock — the grilling-and-glossary planning workflow.

Released under the [MIT License](./LICENSE). Contributions welcome.
