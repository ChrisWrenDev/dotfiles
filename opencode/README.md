# OpenCode Config

A terminal-first OpenCode setup for driving a full research → plan → implement workflow using local task files, persistent `thoughts/` context, and parallel agent sessions.

---

## Installation

This directory is the opencode config. Place it (or symlink it) where opencode looks for configuration:

```bash
# Option A — symlink from dotfiles
ln -s ~/dotfiles/opencode ~/.config/opencode

# Option B — use per-project by placing opencode/ in the repo root
# opencode will discover it automatically
```

Then initialise `thoughts/` for the project:

```bash
# Clone an existing thoughts repo
bash opencode/scripts/thoughts_init.sh git@github.com:you/thoughts.git

# Or create a fresh one
bash opencode/scripts/thoughts_init.sh
```

Create the tasks directory:

```bash
mkdir -p tasks
```

Verify everything is working:

```bash
bash opencode/scripts/thoughts_status.sh
opencode                          # should open with commands available
```

---

## Directory Structure

```
opencode/
├── agents/       Reusable sub-agents spawned by the Task tool
├── commands/     Slash commands (/research_codebase, /create_tasks, /ralph_*, etc.)
└── scripts/      Shell entry points (ralph.sh, thoughts_sync.sh, etc.)

tasks/            One markdown file per task (lives in your project root)
thoughts/         Persistent context: research docs, plans, handoffs (git repo)
```

---

## Task Files

Tasks live in `tasks/` as markdown files. The ralph loop reads their frontmatter to decide what to work on and in what order.

**Format:**

```markdown
---
id: TASK-001
title: Add rate limiting to the API
status: research-needed
size: small        # xs | small  (ralph only processes xs and small)
priority: 2        # 1=urgent  2=high  3=medium  4=low
---

## Problem to Solve

What needs to be done and why.

## Context

Key findings or constraints relevant to this task.

## Links

- Research: thoughts/shared/research/2026-03-21-task-001-api-rate-limiting.md
- Plan: thoughts/shared/plans/2026-03-21-task-001-api-rate-limiting.md
```

**Status flow:**

```
todo
  → research-needed → research-in-progress → research-done
  → plan-needed → plan-in-progress → plan-ready
  → in-dev
  → done
```

The ralph loop acts on: `research-needed`, `research-done`, `plan-needed`, `plan-ready`.
Tasks move to `in-dev` when `ralph_impl` runs, and to `done` when `validate_plan` passes.

---

## End-to-End Workflow

### Phase 1 — Discovery (main repo, one session)

Understand the problem space and generate tasks.

```bash
opencode
```

```
/research_questions          # generate focused research questions for a task or description
/research_codebase           # answer those questions with parallel sub-agent research
/create_tasks                # decompose research findings into task files in tasks/
```

`/create_tasks` proposes a breakdown (with sizing and dependencies) for your review before writing any files.

---

### Phase 2 — Execution (ralph loop)

Drive tasks through research → plan → impl setup from the shell:

```bash
bash opencode/scripts/ralph.sh           # all phases, highest-priority task first
bash opencode/scripts/ralph.sh research  # only research-needed tasks
bash opencode/scripts/ralph.sh plan      # only plan-needed / research-done tasks
bash opencode/scripts/ralph.sh impl      # only plan-ready tasks
```

Each iteration calls one of:
- `opencode run --command /ralph_research --file tasks/TASK-NNN.md`
- `opencode run --command /ralph_plan --file tasks/TASK-NNN.md`
- `opencode run --command /ralph_impl --file tasks/TASK-NNN.md`

When a task reaches `plan-ready`, `ralph_impl` moves it to `in-dev` and prints implementation instructions. The loop then moves on to the next task.

To stop cleanly after the current task finishes:

```bash
touch tasks/.stop
```

---

### Phase 3 — Implementation (per task, in a worktree)

Each `in-dev` task is implemented in its own session. See [Parallel Agents](#parallel-agents-with-tmux--git-worktrees) below for running these concurrently.

```bash
opencode
```

```
/implement_plan thoughts/shared/plans/YYYY-MM-DD-TASK-NNN-description.md
/commit
/validate_plan                # verifies implementation and marks task done
/describe_pr                  # generates PR description
```

---

## Parallel Agents with tmux + Git Worktrees

Running multiple agents simultaneously requires two things:
- **Git worktrees** — isolated working copies so agents don't step on each other's files
- **tmux** — multiple terminal sessions to run them side by side

### Setup

```bash
# Create a worktree for each task being implemented in parallel
git worktree add -b task/TASK-001 ~/wt/myrepo/task-001 main
git worktree add -b task/TASK-002 ~/wt/myrepo/task-002 main
git worktree add -b task/TASK-003 ~/wt/myrepo/task-003 main
```

The `opencode/` config and `thoughts/` are in your main repo. Each worktree needs access to them:

```bash
# Copy the config into each worktree (or symlink)
cp -r opencode ~/wt/myrepo/task-001/opencode
cp -r opencode ~/wt/myrepo/task-002/opencode

# Symlink thoughts/ so all worktrees share the same context
ln -s ~/myrepo/thoughts ~/wt/myrepo/task-001/thoughts
ln -s ~/myrepo/thoughts ~/wt/myrepo/task-002/thoughts
```

### Recommended tmux layout

```
tmux new-session -s work

# Window 0 — main repo: discovery + ralph loop
tmux rename-window "ralph"

# Window 1 — worktree for TASK-001 implementation
tmux new-window -n "task-001" -c "~/wt/myrepo/task-001"

# Window 2 — worktree for TASK-002 implementation
tmux new-window -n "task-002" -c "~/wt/myrepo/task-002"

# Window 3 — monitor / review
tmux new-window -n "review" -c "~/myrepo"
```

Switch between windows: `Ctrl-b 0`, `Ctrl-b 1`, `Ctrl-b 2`, etc.
List windows: `Ctrl-b w`

### Typical parallel session

**Window 0 (main repo) — ralph drives research and planning:**

```bash
bash opencode/scripts/ralph.sh
```

This runs autonomously, working through `research-needed` and `plan-needed` tasks one at a time until they reach `plan-ready` or `in-dev`.

**Windows 1, 2, 3 (worktrees) — implement tasks in parallel:**

As tasks reach `in-dev`, open each worktree in a new window and implement:

```bash
# In ~/wt/myrepo/task-001
opencode run --command /implement_plan \
  --file thoughts/shared/plans/2026-03-21-TASK-001-description.md
```

Or interactively:

```bash
cd ~/wt/myrepo/task-001
opencode
# then: /implement_plan thoughts/shared/plans/2026-03-21-TASK-001-description.md
```

**Coordination:**
- The ralph loop only drives research/plan phases — it never touches `in-dev` tasks
- Each worktree's agent only works on its own branch — no conflicts
- `thoughts/` is shared via symlink, so research docs and plans are visible everywhere
- `tasks/` lives in the main repo; worktree agents update task status via the symlinked path

### Splitting ralph by phase

If you want to parallelise the ralph loop itself — e.g. run research and planning simultaneously — use phase flags in separate windows:

```bash
# Window 0 — research phase only
bash opencode/scripts/ralph.sh research

# Window 1 — plan phase only (starts once research tasks complete)
bash opencode/scripts/ralph.sh plan
```

---

## Commands Reference

### Research & Task Creation

| Command               | Description                                                                                          |
| --------------------- | ---------------------------------------------------------------------------------------------------- |
| `/research_questions` | Generate a structured questions file in `thoughts/` defining what `/research_codebase` should answer |
| `/research_codebase`  | Comprehensive codebase research via parallel sub-agents; writes to `thoughts/shared/research/`       |
| `/create_tasks`       | Decompose research findings into task files in `tasks/`; proposes breakdown before writing           |

### Planning & Implementation

| Command           | Description                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------- |
| `/create_plan`    | Interactive implementation plan creation with codebase research; writes to `thoughts/shared/plans/`           |
| `/iterate_plan`   | Update an existing plan with targeted research                                                                |
| `/implement_plan` | Execute an approved plan phase-by-phase with verification checkpoints                                        |
| `/validate_plan`  | Verify implementation against a plan's success criteria; marks task `done` when passing                      |

### Task Workflow (ralph)

| Command           | Description                                                                                |
| ----------------- | ------------------------------------------------------------------------------------------ |
| `/ralph_research` | Research the highest-priority `research-needed` task file passed via `--file`              |
| `/ralph_plan`     | Create a plan for the highest-priority `plan-needed` or `research-done` task               |
| `/ralph_impl`     | Prepare implementation instructions for the highest-priority `plan-ready` task             |
| `/oneshot`        | Research a specific task then print planning session instructions                          |
| `/oneshot_plan`   | Run `/ralph_plan` then `/ralph_impl` sequentially for a specific task                     |

### Git & PRs

| Command        | Description                                                                                             |
| -------------- | ------------------------------------------------------------------------------------------------------- |
| `/commit`      | Create focused git commits; confirms with user unless called from an automated flow; no Claude attribution |
| `/describe_pr` | Generate a PR description from `thoughts/shared/pr_description.md` or a built-in template              |

### Context & Handoffs

| Command           | Description                                                        |
| ----------------- | ------------------------------------------------------------------ |
| `/create_handoff` | Write a handoff document for transferring work to another session  |
| `/resume_handoff` | Resume work from a previous session's handoff document             |
| `/debug`          | Investigate git state, build output, and environment (read-only)   |

---

## Scripts Reference

Run with `bash opencode/scripts/<name>.sh`.

| Script                        | Description                                                                                        |
| ----------------------------- | -------------------------------------------------------------------------------------------------- |
| `ralph.sh [phase]`            | Shell ralph loop — one task per opencode call; loops until done or `tasks/.stop` exists           |
| `spec_metadata.sh`            | Print repo metadata (datetime, git hash, branch, repo name) for document frontmatter              |
| `thoughts_sync.sh [message]`  | Stage, commit, and push all changes in `thoughts/`                                                 |
| `thoughts_init.sh [repo-url]` | Bootstrap `thoughts/` — clone from URL or create empty structure                                  |
| `thoughts_status.sh`          | Show `thoughts/` git branch, tracking status, and uncommitted changes                             |

---

## Agents Reference

Sub-agents invoked via the `Task` tool inside commands. All are documentarians — they describe what exists without suggesting improvements.

| Agent                     | Purpose                                                              |
| ------------------------- | -------------------------------------------------------------------- |
| `codebase-locator`        | Find where files and components live (grep/glob only)                |
| `codebase-analyzer`       | Understand how specific code works (reads files, no critique)        |
| `codebase-pattern-finder` | Find similar existing implementations to model after                 |
| `thoughts-locator`        | Discover relevant documents in `thoughts/` by topic                  |
| `thoughts-analyzer`       | Extract key insights from specific thoughts documents                |
| `web-search-researcher`   | Research external docs, APIs, and best practices via web search      |

---

## `thoughts/` Directory

```
thoughts/
├── shared/
│   ├── research/    YYYY-MM-DD[-TASK-NNN]-description.md
│   ├── plans/       YYYY-MM-DD[-TASK-NNN]-description.md
│   ├── prs/         {pr-number}_description.md
│   └── handoffs/    TASK-NNN/YYYY-MM-DD_HH-MM-SS_description.md
```

`thoughts/` is either its own git repo cloned into the project root, or a directory inside the main repo. All worktrees should symlink to the same `thoughts/` so context is shared across sessions.

---

## Permission Model

Defined in `opencode.json`. Default is `ask` for everything not listed.

| Category                                                   | Policy                          |
| ---------------------------------------------------------- | ------------------------------- |
| Read files                                                 | Allow (except `.env`, `.env.*`) |
| Navigation (glob, grep, list, lsp, task)                   | Allow                           |
| Edit files                                                 | Ask                             |
| `opencode/scripts/thoughts_status.sh`, `spec_metadata.sh` | Allow                           |
| `opencode/scripts/thoughts_sync.sh`, `thoughts_init.sh`   | Ask                             |
| Git read commands (status, diff, log, branch, show…)       | Allow                           |
| Build/test/lint (make, go, npm, bun, npx)                  | Allow                           |
| GitHub CLI read (pr view, issue view, repo view, api)      | Allow                           |
| Web (webfetch, websearch)                                  | Ask                             |
| Destructive bash (rm, sudo, chmod, pipe to bash)           | Deny                            |

---

## Model Assignments

| Context                              | Model                          |
| ------------------------------------ | ------------------------------ |
| Default (agents, most commands)      | `anthropic/claude-sonnet-4-6`  |
| Research and planning commands       | `anthropic/claude-opus-4-6`    |

Commands that use opus: `create_plan`, `create_tasks`, `iterate_plan`, `research_codebase`, `ralph`.

---

## Setup Checklist

- [ ] Symlink or copy `opencode/` to `~/.config/opencode` (or keep per-project)
- [ ] Run `bash opencode/scripts/thoughts_init.sh [repo-url]` to initialise `thoughts/`
- [ ] Create `tasks/` directory in project root
- [ ] Replace `<username>` placeholder in `agents/thoughts-locator.md`
- [ ] Add a PR description template at `thoughts/shared/pr_description.md`
- [ ] Run `bash opencode/scripts/thoughts_status.sh` to confirm `thoughts/` is healthy
- [ ] Open `opencode` and verify commands are available (type `/` to list)
