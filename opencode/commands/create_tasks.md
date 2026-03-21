---
description: Generate task files in tasks/ from research findings or a problem description
model: anthropic/claude-opus-4-6
---

# Create Tasks

Given research findings or a problem description, generate properly formatted task files in `tasks/` ready for the ralph loop to execute.

## Input

One or more of:
- Path(s) to research documents in `thoughts/shared/research/`
- Path(s) to research questions files
- A plain description of what needs to be built

If nothing is provided, ask:

```
What would you like to create tasks for?
Provide research doc paths (e.g. thoughts/shared/research/...) or describe the work.
```

## Process

### 1. Read all inputs

Read every provided file fully. If a plain description was given, work from that directly.

### 2. Determine the next task ID

List the `tasks/` directory. Find the highest existing `TASK-NNN` number and increment from there. If `tasks/` is empty or does not exist, start at `TASK-001`.

### 3. Think deeply about task decomposition

Before writing anything, reason through:

- What are the discrete units of work that emerge from this research?
- What is the right granularity? (Too coarse = hard to execute; too fine = unnecessary overhead)
- Which tasks depend on others and in what order should they be done?
- Which tasks are small or xs? Large tasks should be split.
- What is already understood well enough to plan immediately, vs what needs more specific research first?

A good task:
- Has a clear, singular goal
- Can be implemented in one focused session
- Has enough context to research and plan without ambiguity
- Is `xs` or `small` in size (prefer splitting over larger tasks)

### 4. Present the proposed task breakdown

Before creating any files, show the user the proposed tasks:

```
Proposed tasks from [source]:

TASK-001 [xs, P2] Add database migration for user preferences table
TASK-002 [small, P2] Implement preferences API endpoints (GET/PUT)
TASK-003 [small, P3] Add preferences UI settings panel

Task TASK-002 depends on TASK-001.
TASK-003 can be done in parallel with TASK-002.

Does this breakdown look right? Should I adjust sizing, split any tasks, or change priorities?
```

Wait for confirmation or adjustments before writing files.

### 5. Determine starting status

For each task, set the initial status based on what is already known:

- **`plan-needed`** — research was provided and is sufficient to start planning immediately
- **`research-needed`** — the task needs its own targeted codebase research before planning

Ask if unclear:

```
Should these tasks go straight to planning (research already done),
or does each need its own codebase research first?
```

### 6. Write task files

Create `tasks/TASK-NNN.md` for each task. Create the `tasks/` directory if it does not exist.

Use this format:

```markdown
---
id: TASK-NNN
title: [concise imperative title]
status: [plan-needed | research-needed]
size: [xs | small]
priority: [1=urgent | 2=high | 3=medium | 4=low]
---

## Problem to Solve

[What needs to be done and why. Written so someone can plan and implement this without needing the original research doc.]

## Context

[Key findings from the research that are directly relevant to this task. Include specific file paths, patterns, or constraints discovered.]

## Links

- Research: [path to research doc if applicable]
```

### 7. Report

```
✅ Created [N] task(s):

  TASK-001 (plan-needed, xs, P2) → tasks/TASK-001.md
  TASK-002 (plan-needed, small, P2) → tasks/TASK-002.md
  TASK-003 (research-needed, small, P3) → tasks/TASK-003.md

Next step:
  /ralph          — run the full autonomous loop across all tasks
  /ralph plan     — jump straight to planning (if all tasks are plan-needed)
  /ralph_plan tasks/TASK-001.md  — work a single task
```
