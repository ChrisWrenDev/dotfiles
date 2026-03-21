---
description: Research highest priority task needing investigation
---

## PART I - IF A TASK FILE IS MENTIONED

0c. read the task file from the `tasks/` directory (e.g., `tasks/TASK-001.md`)
0d. read the task content and any linked documents to understand what research is needed

## PART I - IF NO TASK IS MENTIONED

0.  read all task files in the `tasks/` directory
    0a. read each file's frontmatter to find tasks with `status: research-needed`
    0b. select the highest priority `small` or `xs` task (if none exist, EXIT IMMEDIATELY and inform the user)
    0c. read the selected task file fully
    0d. understand what research is needed from the task description and any linked documents

## PART II - NEXT STEPS

think deeply

1. update the task file: set `status: research-in-progress`
   1a. read any documents listed in the task's `## Links` section for context
   1b. if there is insufficient information to conduct research, add a note to the task file asking for clarification and EXIT

think deeply about the research needs

2. conduct the research:
   2a. read opencode/commands/research_codebase.md for guidance on effective codebase research
   2b. if the task description suggests web research is needed, use WebSearch to research external solutions, APIs, or best practices
   2c. search the codebase for relevant implementations and patterns
   2d. examine existing similar features or related code
   2e. identify technical constraints and opportunities
   2f. Be unbiased - don't think too much about an ideal implementation plan, just document all related files and how the systems work today
   2g. document findings in a new thoughts document: `thoughts/shared/research/YYYY-MM-DD-TASK-XXX-description.md`
   - Format: `YYYY-MM-DD-TASK-XXX-description.md` where:
     - YYYY-MM-DD is today's date
     - TASK-XXX is the task ID (omit if no ID)
     - description is a brief kebab-case description of the research topic

think deeply about the findings

3. synthesize research into actionable insights:
   3a. summarize key findings and technical decisions
   3b. identify potential implementation approaches
   3c. note any risks or concerns discovered
   3d. run `bash opencode/scripts/thoughts_sync.sh` to save the research

4. update the task file:
   4a. add the research document path under the `## Links` section
   4b. set `status: research-done`

think deeply, use TodoWrite to track your tasks.

## PART III - When you're done

Print a message for the user (replace placeholders with actual values):

```
✅ Completed research for [task ID]: [task title]

Research topic: [research topic description]

The research has been:

Created at thoughts/shared/research/YYYY-MM-DD-TASK-XXX-description.md
Synced to thoughts repository
Task updated to "research-done"

Key findings:
- [Major finding 1]
- [Major finding 2]
- [Major finding 3]
```
