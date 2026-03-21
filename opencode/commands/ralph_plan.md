---
description: Create implementation plan for highest priority task ready for planning
---

## PART I - IF A TASK FILE IS MENTIONED

0c. read the task file from the `tasks/` directory (e.g., `tasks/TASK-001.md`)
0d. read the task and any linked research documents from its `## Links` section

## PART I - IF NO TASK IS MENTIONED

0.  read all task files in the `tasks/` directory
    0a. read each file's frontmatter to find tasks with `status: plan-needed` or `status: research-done`
    0b. select the highest priority `small` or `xs` task (if none exist, EXIT IMMEDIATELY and inform the user)
    0c. read the selected task file fully
    0d. read any linked research documents from the task's `## Links` section

## PART II - NEXT STEPS

think deeply

1. update the task file: set `status: plan-in-progress`
   1a. read opencode/commands/create_plan.md
   1b. check the task's `## Links` section for an existing implementation plan
   1c. if a plan already exists, set `status: plan-ready` and EXIT with the plan path
   1d. if research is insufficient or has unanswered questions, create the plan following opencode/commands/create_plan.md

think deeply

2. when the plan is complete, use the `thoughts_sync` tool and update the task file:
   2a. add the plan document path to the task's `## Links` section
   2b. set `status: plan-ready`

think deeply, use TodoWrite to track your tasks.

## PART III - When you're done

Print a message for the user (replace placeholders with actual values):

```
✅ Completed implementation plan for [task ID]: [task title]

Approach: [selected approach description]

The plan has been:

Created at thoughts/shared/plans/YYYY-MM-DD-TASK-XXX-description.md
Synced to thoughts repository
Task updated to "plan-ready"

Implementation phases:
- Phase 1: [phase 1 description]
- Phase 2: [phase 2 description]
- Phase 3: [phase 3 description if applicable]
```
