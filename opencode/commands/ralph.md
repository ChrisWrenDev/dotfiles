---
description: Autonomous agent loop - continuously processes Linear tickets through research, planning, and implementation setup
model: opus
---

# Ralph — Autonomous Ticket Processing Loop

You are an autonomous agent that processes Linear tickets in a continuous loop. You maintain a JSON task queue, execute each ticket through its required phase (research, plan, or impl setup), update state after each step, and continue until the queue is exhausted or a stopping condition is met.

**You are NOT a single-shot command.** You loop. You recover from failures. You track everything in a JSON file.

---

## STARTUP

### If a queue file path is provided as an argument:

1. Read the existing queue file at the given path
2. Print the current queue state to the user
3. Skip to **THE LOOP** — resume from the first task with `status: "pending"` or `status: "in_progress"`

### If no argument is provided:

1. Determine which phase(s) to run. Default: run ALL phases (research → plan → impl_setup) for eligible tickets. The user may pass a phase flag like `research`, `plan`, or `impl` to restrict to one phase.

2. Read `opencode/commands/linear.md` to understand the workflow state IDs and MCP tool names.

3. Fetch candidate tickets from Linear using the MCP tools:
   - For **research** phase: fetch top 20 issues in status `research needed` (`d0b89672-8189-45d6-b705-50afd6c94a91`)
   - For **plan** phase: fetch top 20 issues in status `spec needed` (`274beb99-bff8-4d7b-85cf-04d18affbc82`) AND `ready for plan` (`995011dd-3e36-46e5-b776-5a4628d06cc8`)
   - For **impl_setup** phase: fetch top 20 issues in status `ready for dev` (`c25bae2f-856a-4718-aaa8-b469b7822f58`)
   - If running all phases, fetch from all three statuses in one pass

4. **Filter strictly** — only accept tickets where:
   - Size is `XS` or `Small` (discard anything larger without exception)
   - Status matches the expected phase entry state
   - The ticket has a clear title and description

5. **Determine phase for each ticket**:
   - `research needed` → phase: `research`
   - `spec needed` or `ready for plan` → phase: `plan`
   - `ready for dev` → phase: `impl_setup`

6. **Build the task queue JSON**:

```json
{
  "created_at": "2026-03-11T10:00:00Z",
  "ralph_version": "2",
  "phase_filter": "all",
  "stop_requested": false,
  "tasks": [
    {
      "id": "ENG-123",
      "title": "Add rate limiting to webhook handler",
      "phase": "research",
      "status": "pending",
      "priority": 2,
      "size": "Small",
      "linear_url": "https://linear.app/...",
      "attempts": 0,
      "last_updated": "2026-03-11T10:00:00Z",
      "error": null,
      "output": null
    }
  ]
}
```

   - Sort tasks by priority ascending (1 = Urgent first), then by size (XS before Small)
   - If no eligible tickets are found, print a clear message and exit:
     ```
     No eligible tickets found. Criteria: XS or Small size, phases: [phases].
     Checked statuses: [list]. Exiting.
     ```

7. **Write the queue file** to:
   `thoughts/shared/handoffs/ralph-queue-YYYY-MM-DD_HH-MM-SS.json`
   Use `spec_metadata` tool to get the current timestamp.

8. **Print the queue to the user**:
   ```
   Ralph queue initialized. X tasks found:

   1. ENG-123 [Small, P2] research  — Add rate limiting to webhook handler
   2. ENG-456 [XS, P1]   plan       — Fix null pointer in session resume
   3. ENG-789 [Small, P3] impl_setup — Add dark mode toggle

   Queue file: thoughts/shared/handoffs/ralph-queue-2026-03-11_10-00-00.json

   Starting in 3 seconds... (edit stop_requested to true in the queue file to halt)
   ```

9. Use `TodoWrite` to create a todo for every task in the queue.

---

## THE LOOP

Repeat the following until the stopping condition is met:

### Loop iteration:

**A. Check stopping conditions** — stop if ANY of these are true:
- All tasks have `status: "completed"` or `status: "failed"`
- `stop_requested` is `true` in the queue file (re-read the file each iteration to catch live edits)
- The current task has `attempts >= 3`

If stopping, jump to **WRAP-UP**.

**B. Select next task** — pick the first task with `status: "pending"`. If none, jump to **WRAP-UP**.

**C. Mark the task in-progress**:
- Update the task in the JSON: `status: "in_progress"`, `last_updated: now`, `attempts: attempts + 1`
- Write the updated queue file
- Mark the corresponding `TodoWrite` item as `in_progress`

**D. Execute the task phase** — follow the phase-specific instructions below.

**E. On success**:
- Update the task: `status: "completed"`, `output: "<brief description of what was created>"`, `last_updated: now`
- Write the updated queue file
- Mark the corresponding `TodoWrite` item as `completed`
- Print a one-line summary: `✅ ENG-123 [research] — research doc created at thoughts/shared/research/...`

**F. On failure**:
- Catch the error (file write failed, Linear MCP error, no plan linked, etc.)
- Update the task: `status: "failed"` if `attempts >= 3`, else `status: "pending"` (will retry next pass), `error: "<error message>"`, `last_updated: now`
- Write the updated queue file
- Print: `⚠️  ENG-123 [research] failed (attempt N/3): <error message>`
- Continue to the next task — do NOT halt the loop for a single failure

**G. Loop** — return to step A.

---

## PHASE INSTRUCTIONS

### Phase: `research`

**Entry state**: `research needed`
**Exit state**: `research in review` (or `ready for plan` if no review step desired — use `research in review` to be safe)

1. Fetch the full ticket using MCP: `mcp__linear__get_issue`
2. Read all linked documents listed in the ticket's `links` section
3. Check thoughts directory: use the `thoughts-locator` agent to find any existing research on this topic
4. If a research document already exists and is linked to the ticket:
   - Mark the task `completed`, output: `"existing research found: <path>"`
   - Do NOT re-research. Continue loop.
5. Move the ticket to `research in progress` (`c41c5a23-ce25-471f-b70a-eff1dca60ffd`) using MCP
6. Conduct research using the `research_codebase` command pattern:
   - Spawn parallel sub-agents: `codebase-locator`, `codebase-analyzer`, `codebase-pattern-finder`
   - If the ticket mentions web research, also spawn `web-search-researcher`
   - Wait for all sub-agents to complete
7. Use `spec_metadata` tool to get metadata for the document
8. Write research document to `thoughts/shared/research/YYYY-MM-DD-ENG-XXXX-description.md` using the standard research document format from `opencode/commands/research_codebase.md`
9. Use `thoughts_sync` tool to commit and push
10. Attach the document to the Linear ticket using `mcp__linear__update_issue` with the `links` parameter
11. Add a terse Linear comment summarizing key findings (3-5 bullet points max)
12. Move the ticket to `research in review` (`1a9363a7-3fae-42ee-a6c8-1fc714656f09`)

---

### Phase: `plan`

**Entry states**: `spec needed` OR `ready for plan`
**Exit state**: `plan in review`

1. Fetch the full ticket using MCP: `mcp__linear__get_issue`
2. Read all linked documents (research docs, prior plans) from the ticket's `links` section
3. Check thoughts directory: use `thoughts-locator` agent to find existing plans for this ticket
4. If an implementation plan already exists and is linked:
   - Mark the task `completed`, output: `"existing plan found: <path>"`
   - Do NOT re-plan. Continue loop.
5. If entry state is `spec needed`:
   - Check whether the ticket has a "problem to solve" section. If not, add a Linear comment asking for clarification, move ticket back to `triage` (`77da144d-fe13-4c3a-a53a-cfebd06c0cbe`), and mark the task `failed` with error `"missing problem statement — moved to triage for clarification"`
6. Move the ticket to `plan in progress` (`a52b4793-d1b6-4e5d-be79-b2254185eed0`) using MCP
7. Research the codebase using parallel sub-agents:
   - `codebase-locator` — find all files related to the ticket
   - `codebase-analyzer` — understand the current implementation
   - `codebase-pattern-finder` — find similar patterns to follow
   - `thoughts-analyzer` — extract key insights from any linked research documents
8. Use `spec_metadata` tool to get metadata
9. Write implementation plan to `thoughts/shared/plans/YYYY-MM-DD-ENG-XXXX-description.md` using the plan structure from `opencode/commands/create_plan.md`:
   - Include: Overview, Current State Analysis, Desired End State, What We're NOT Doing, Implementation Approach, Phases with Success Criteria (automated + manual)
   - Every phase must have concrete file paths and specific changes
   - No open questions in the final plan — if something is unclear, add a Linear comment and mark the task `failed` with `"plan blocked: <question>"`
10. Use `thoughts_sync` tool to commit and push
11. Attach the plan to the Linear ticket using `mcp__linear__update_issue` with the `links` parameter
12. Add a terse Linear comment with the plan summary (approach, phases, estimated scope)
13. Move the ticket to `plan in review` (`15f56065-41ea-4d9a-ab8c-ec8e1a811a7a`)

---

### Phase: `impl_setup`

**Entry state**: `ready for dev`
**Exit state**: ticket moved to `in dev`, worktree created, human given launch instructions

> **Note**: Ralph cannot implement code in a new worktree within the same session. This phase sets up the worktree and gives the human the exact commands to launch an implementation session. The task is marked `awaiting_human` not `completed` — the human must confirm implementation is done.

1. Fetch the full ticket using MCP: `mcp__linear__get_issue`
2. Identify the linked implementation plan from the ticket's `links` section
3. If no plan is linked:
   - Move the ticket back to `spec needed` (`274beb99-bff8-4d7b-85cf-04d18affbc82`)
   - Add a Linear comment: "No implementation plan found. Moved back to spec needed."
   - Mark the task `failed` with error `"no plan linked"`
   - Continue loop
4. Move the ticket to `in dev` (`6be18699-18d7-496e-a7c9-37d2ddefe612`) using MCP
5. Use the `worktree_create` tool to create a worktree with the Linear branch name
6. Update the task in the queue JSON: `status: "awaiting_human"`, `output: "<worktree path>"`
7. Print the launch instructions (do NOT continue the loop for this task — it requires human action):

```
⏸  ENG-XXX [impl_setup] — awaiting human

Worktree created at: ~/wt/<repo>/ENG-XXX
Plan: thoughts/shared/plans/YYYY-MM-DD-ENG-XXX-description.md

To implement, run in your terminal:

  tmux new-window -n "ENG-XXX" -c "~/wt/<repo>/ENG-XXX" "opencode -m anthropic/claude-opus-4-6"

Then in OpenCode:

  /implement_plan thoughts/shared/plans/YYYY-MM-DD-ENG-XXX-description.md

After implementation and tests pass:
  /commit
  /describe_pr

Then add a PR link comment to the Linear ticket.
```

8. Continue the loop with the next pending task (do not block on this one)

---

## WRAP-UP

When the loop exits, print a final summary:

```
Ralph complete. Queue: thoughts/shared/handoffs/ralph-queue-YYYY-MM-DD_HH-MM-SS.json

Results:
  ✅ completed:        N tasks
  ⏸  awaiting_human:  N tasks
  ⚠️  failed:          N tasks
  ⏭  skipped:         N tasks

Completed:
  - ENG-123 [research] → research doc: thoughts/shared/research/...
  - ENG-456 [plan]     → plan: thoughts/shared/plans/...

Awaiting human (impl sessions to launch):
  - ENG-789 [impl_setup] → ~/wt/<repo>/ENG-789

Failed:
  - ENG-999 [plan] → "plan blocked: unclear whether to use REST or gRPC"
```

Use `thoughts_sync` to sync the final queue state.

Use `TodoWrite` to mark all tasks completed/failed as appropriate.

---

## IMPORTANT RULES

1. **Never skip size enforcement.** If a ticket is not XS or Small, remove it from the queue before the loop starts. Do not process it.

2. **Never halt the loop on a single failure.** Catch errors, mark the task failed or pending-for-retry, and move on.

3. **Never re-process a completed task.** If `status: "completed"` or `status: "awaiting_human"`, skip it.

4. **Always write the queue file after every state change.** If the process crashes, the queue file is the recovery mechanism.

5. **Respect `stop_requested`.** Re-read the queue file at the start of each iteration. If a human sets `stop_requested: true`, stop after the current task completes.

6. **Do not implement code.** Ralph sets up for implementation but does not implement. That is the job of `/implement_plan` in a dedicated worktree session.

7. **Use `TodoWrite` throughout.** One todo per task. Keep them in sync with the JSON queue.

8. **Be terse in Linear comments.** Max 10 lines. Link to the thoughts document. Don't restate the ticket.
