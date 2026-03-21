---
description: Set up implementation for highest priority task ready for dev
model: sonnet
---

## PART I - IF A TASK FILE IS MENTIONED

0c. read the task file from the `tasks/` directory (e.g., `tasks/TASK-001.md`)
0d. read the task and any linked documents to understand the implementation plan and any concerns

## PART I - IF NO TASK IS MENTIONED

0.  read all task files in the `tasks/` directory
    0a. read each file's frontmatter to find tasks with `status: plan-ready`
    0b. select the highest priority `small` or `xs` task (if no `small` or `xs` tasks exist, EXIT IMMEDIATELY and inform the user)
    0c. read the selected task file fully
    0d. read any linked documents to understand the implementation plan and any concerns

## PART II - NEXT STEPS

think deeply

1. update the task file: set `status: in-dev`
   1a. identify the linked implementation plan document from the task's `## Links` section
   1b. if no plan exists, set `status: plan-needed` and EXIT with an explanation

think deeply about the implementation

2. Provide instructions for the implementation session:

```
Open a new OpenCode session in your worktree and run:

/implement_plan [path-to-plan]

After implementation completes and tests pass:
/commit
/describe_pr
```

think deeply, use TodoWrite to track your tasks.
