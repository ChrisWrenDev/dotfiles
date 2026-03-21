# OpenCode Config

A terminal-first OpenCode setup built around four pillars:

- **Approval gating** — every destructive or mutating action requires explicit permission
- **Parallel sessions** — multiple OpenCode sessions for concurrent work on multiple tickets
- **Persistent context** — a `thoughts/` directory tracked in git holds research, plans, and handoffs across sessions
- **Linear integration** — slash commands drive tickets through a full research → plan → implement workflow

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

| Command                      | Description                                                                                                              |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `/research_codebase`         | Comprehensive codebase research with parallel sub-agents; writes a research doc to `thoughts/shared/research/` and syncs |
| `/research_codebase_nt`      | Same, without `thoughts/` integration; uses `/tmp` for output                                                            |
| `/research_codebase_generic` | Generic version with no team-specific references                                                                         |

### Planning

| Command                | Description                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| `/create_plan`         | Interactive implementation plan creation with codebase research; writes to `thoughts/shared/plans/` |
| `/create_plan_nt`      | Same, without `thoughts/` integration                                                               |
| `/create_plan_generic` | Generic version                                                                                     |
| `/iterate_plan`        | Update an existing plan with new research                                                           |
| `/iterate_plan_nt`     | Same, without `thoughts/` integration                                                               |
| `/validate_plan`       | Verify an implementation against a plan's success criteria                                          |
| `/implement_plan`      | Execute an approved plan phase-by-phase with verification                                           |

### Linear Workflow

| Command           | Description                                                                                                                                                                    |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/linear`         | Full Linear ticket management — create, update, comment, attach documents                                                                                                      |
| `/ralph`          | **Autonomous loop**: fetches a queue of XS/Small tickets from Linear, processes them through research → plan → impl setup, maintains a JSON task queue with retry and recovery |
| `/ralph_research` | Single-shot: research the highest-priority "research needed" ticket                                                                                                            |
| `/ralph_plan`     | Single-shot: create a plan for the highest-priority "spec needed" ticket                                                                                                       |
| `/ralph_impl`     | Single-shot: prepare implementation instructions for the highest-priority "ready for dev" ticket                                                                               |
| `/oneshot`        | Research a specific ticket then output planning session launch instructions                                                                                                    |
| `/oneshot_plan`   | Run `/ralph_plan` then `/ralph_impl` sequentially for a specific ticket                                                                                                        |
| `/founder_mode`   | Retroactively create a Linear ticket and PR for an experimental commit                                                                                                         |

### Git & PRs

| Command           | Description                                                              |
| ----------------- | ------------------------------------------------------------------------ |
| `/commit`         | Create a git commit with user approval; no Claude attribution in message |
| `/ci_commit`      | Same, without user approval step (for CI/unattended use)                 |
| `/describe_pr`    | Generate a PR description from a template in `thoughts/shared/`          |
| `/describe_pr_nt` | Same, with an embedded template; saves to `/tmp`                         |
| `/ci_describe_pr` | CI-mode PR description using the `thoughts/shared/` template             |

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

### Autonomous ticket processing (`/ralph`)

```
/ralph                    # process all eligible XS/Small tickets across all phases
/ralph research           # only process "research needed" tickets
/ralph plan               # only process "spec needed" / "ready for plan" tickets
/ralph impl               # only process "ready for dev" tickets
/ralph <queue-file>       # resume from an existing queue file
```

Ralph maintains a JSON queue at `thoughts/shared/handoffs/ralph-queue-TIMESTAMP.json`. Each task has `status`, `attempts`, `error`, and `output` fields. Set `stop_requested: true` in the file to halt cleanly after the current task.

### Single-ticket loop

```
/ralph_research ENG-1234  →  research doc created, ticket → "research in review"
/ralph_plan ENG-1234      →  plan created, ticket → "plan in review"
/ralph_impl ENG-1234      →  implementation instructions printed
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

## Linear Workflow States

```
Triage → Spec Needed → Research Needed → Research in Progress
       → Research in Review → Ready for Plan → Plan in Progress
       → Plan in Review → Ready for Dev → In Dev → Code Review → Done
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
- [ ] Set your canonical GitHub URL pattern for `thoughts/` document links (in `linear.md` or an `AGENTS.md`)
- [ ] Replace `<username>` placeholder in `agents/thoughts-locator.md` with your actual username
- [ ] Replace the hardcoded Linear UUIDs in `commands/linear.md` with your own org's IDs
- [ ] Run `opencode` and verify all custom tools load without errors
- [ ] Run `thoughts_status` to confirm `thoughts/` git state is healthy
