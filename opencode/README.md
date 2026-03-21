# OpenCode Config

A terminal-first OpenCode setup built around four pillars:

- **Approval gating** — every destructive or mutating action requires explicit permission
- **Parallel sessions** — multiple OpenCode sessions for concurrent work on multiple tickets
- **Persistent context** — a `thoughts/` directory tracked in git holds research, plans, and handoffs across sessions
- **Local task management** — slash commands drive tasks through a full research → plan → implement workflow

---

## Directory Structure

```
opencode/
├── opencode.json       # Permissions, env vars, MCP settings
├── agents/             # Reusable sub-agents spawned by Task tool
├── commands/           # Slash commands (/research_codebase, /ralph, etc.)
└── tools/              # Custom TypeScript tools (thoughts_sync, worktree_create, etc.)
```

---

## Permission Model

Defined in `opencode.json`. Default is `ask` for everything not listed.

| Category                                              | Policy                          |
| ----------------------------------------------------- | ------------------------------- |
| Read files                                            | Allow (except `.env`, `.env.*`) |
| Navigation (glob, grep, list, lsp, task)              | Allow                           |
| Edit files                                            | Ask                             |
| `thoughts_status`, `spec_metadata`                    | Allow (read-only tools)         |
| `thoughts_sync`, `thoughts_init`                      | Ask                             |
| Git read commands (status, diff, log, branch, show…)  | Allow                           |
| Build/test/lint (make, go, npm, bun, npx)             | Allow                           |
| GitHub CLI read (pr view, issue view, repo view, api) | Allow                           |
| Web (webfetch, websearch)                             | Ask                             |
| Destructive bash (rm, sudo, chmod, pipe to bash)      | Deny                            |

---

## Custom Tools

Implemented in TypeScript under `tools/`. Loaded automatically by OpenCode.

### `thoughts_sync`

Stage all changes in `thoughts/`, commit with a timestamp message (or custom message), and push to remote. Use after creating any research doc, plan, or handoff.

### `thoughts_init`

Bootstrap the `thoughts/` directory. Either clones an existing repo or creates the standard empty directory structure:

```
thoughts/
├── shared/
│   ├── research/
│   ├── plans/
│   ├── tickets/
│   ├── prs/
│   └── handoffs/
└── <username>/
```

### `thoughts_status`

Show the git status of `thoughts/` — branch, tracking info, and uncommitted changes.

### `spec_metadata`

Collect repo metadata for use in document frontmatter: current datetime, git commit hash, branch name, repo name, filename-safe timestamp, and thoughts/ branch status.

---

## Agents

Reusable sub-agents under `agents/`. Invoked via the `Task` tool inside commands.

| Agent                     | Purpose                                                                          |
| ------------------------- | -------------------------------------------------------------------------------- |
| `codebase-locator`        | Find _where_ files and components live (grep/glob only, no file reading)         |
| `codebase-analyzer`       | Understand _how_ specific code works (reads files, documents without critiquing) |
| `codebase-pattern-finder` | Find similar existing implementations to model after                             |
| `thoughts-locator`        | Discover relevant documents in `thoughts/` by topic                              |
| `thoughts-analyzer`       | Extract key insights from specific thoughts documents                            |
| `web-search-researcher`   | Research external docs, APIs, and best practices via web search                  |

All agents are configured as **documentarians, not critics** — they describe what exists without suggesting improvements.

---

## Slash Commands

### Research

| Command               | Description                                                                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/research_codebase`  | Comprehensive codebase research with parallel sub-agents; writes to `thoughts/shared/research/` if available, otherwise `/tmp/research/`                 |

### Planning

| Command           | Description                                                                                                                                       |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/create_plan`    | Interactive implementation plan creation with codebase research; writes to `thoughts/shared/plans/` if available, otherwise `./plans/`            |
| `/iterate_plan`   | Update an existing plan with targeted research                                                                                                    |
| `/validate_plan`  | Verify an implementation against a plan's success criteria                                                                                        |
| `/implement_plan` | Execute an approved plan phase-by-phase with verification                                                                                         |

### Task Workflow

| Command           | Description                                                                                                                                                            |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/ralph`          | **Autonomous loop**: reads tasks from `tasks/`, processes them through research → plan → impl setup, maintains a JSON task queue with retry and recovery               |
| `/ralph_research` | Single-shot: research the highest-priority `research-needed` task                                                                                                      |
| `/ralph_plan`     | Single-shot: create a plan for the highest-priority `plan-needed` task                                                                                                 |
| `/ralph_impl`     | Single-shot: prepare implementation instructions for the highest-priority `plan-ready` task                                                                            |
| `/oneshot`        | Research a specific task then output planning session instructions                                                                                                     |
| `/oneshot_plan`   | Run `/ralph_plan` then `/ralph_impl` sequentially for a specific task                                                                                                  |

### Git & PRs

| Command        | Description                                                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `/commit`      | Create focused git commits; confirms with user by default, executes immediately when called from automated flows; no Claude attribution |
| `/describe_pr` | Generate a PR description; reads template from `thoughts/shared/` if available, otherwise uses built-in template                      |

### Session Management

| Command   | Description                                                               |
| --------- | ------------------------------------------------------------------------- |
| `/debug`  | Investigate git state, build output, and environment without making edits |

### Context & Handoffs

| Command           | Description                                                       |
| ----------------- | ----------------------------------------------------------------- |
| `/create_handoff` | Write a handoff document for transferring work to another session |
| `/resume_handoff` | Resume work from a previous session's handoff document            |

---

## Workflow Patterns

### Autonomous task processing (`/ralph`)

```
/ralph                    # process all eligible xs/small tasks across all phases
/ralph research           # only process "research-needed" tasks
/ralph plan               # only process "plan-needed" / "research-done" tasks
/ralph impl               # only process "plan-ready" tasks
/ralph <queue-file>       # resume from an existing queue file
```

Ralph reads tasks from the `tasks/` directory. Each task file has frontmatter fields: `id`, `title`, `status`, `size`, `priority`. Ralph maintains a JSON queue at `thoughts/shared/handoffs/ralph-queue-TIMESTAMP.json` for loop state and retry tracking. Set `stop_requested: true` in the queue file to halt cleanly after the current task.

### Single-task loop

```
/ralph_research tasks/TASK-001.md  →  research doc created, task → "research-done"
/ralph_plan tasks/TASK-001.md      →  plan created, task → "plan-ready"
/ralph_impl tasks/TASK-001.md      →  implementation instructions printed
```

### Manual implementation workflow

```bash
# 1. Open a new OpenCode session in your worktree
# 2. Implement
/implement_plan thoughts/shared/plans/2026-03-11-ENG-1234-description.md

# 3. Commit and open PR
/commit
/describe_pr
```

### Session handoffs

```
/create_handoff            # write handoff doc before context window fills
/resume_handoff            # in new session, pick up where you left off
```

---

## Task Workflow States

Tasks live in the `tasks/` directory as markdown files with frontmatter.

```
todo → research-needed → research-in-progress → research-done
     → plan-needed → plan-in-progress → plan-ready
     → in-dev → done
```

Key principle: review and alignment happen at the **plan stage**, not the PR stage.

---

## `thoughts/` Directory Conventions

```
thoughts/
├── shared/
│   ├── research/    YYYY-MM-DD[-ENG-XXXX]-description.md
│   ├── plans/       YYYY-MM-DD[-ENG-XXXX]-description.md
│   ├── tickets/     ENG-XXXX.md
│   ├── prs/         {pr-number}_description.md
│   └── handoffs/    ENG-XXXX/YYYY-MM-DD_HH-MM-SS_description.md
├── <username>/      Personal notes and tickets
├── global/          Cross-repo thoughts
└── searchable/      Hard-linked read-only view (search here, edit in source)
```

`thoughts/` can either be its own git repo (cloned into the project root) or a directory inside the main repo. Decide before promoting this config to `~/.config/opencode`.

---

## Model Assignments

| Context                                         | Model                                    |
| ----------------------------------------------- | ---------------------------------------- |
| Default (agents, most commands)      | `sonnet` (`anthropic/claude-sonnet-4-6`) |
| Heavy research and planning commands | `opus` (`anthropic/claude-opus-4-6`)     |
| Haiku shortcut                       | `anthropic/claude-haiku-4-5`             |

Commands that use opus: `create_plan`, `create_plan_nt`, `create_plan_generic`, `iterate_plan`, `iterate_plan_nt`, `research_codebase`, `research_codebase_nt`, `research_codebase_generic`, `ralph`.

---

## Setup Checklist

- [ ] Decide: `thoughts/` as its own git repo, or inside the main repo
- [ ] Set your canonical GitHub URL pattern for `thoughts/` document links (in an `AGENTS.md`)
- [ ] Replace `<username>` placeholder in `agents/thoughts-locator.md` with your actual username
- [ ] Create a `tasks/` directory in your project root for local task files
- [ ] Run `opencode` and verify all custom tools load without errors
- [ ] Run `thoughts_status` to confirm `thoughts/` git state is healthy
