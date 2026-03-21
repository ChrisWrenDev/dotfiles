---
description: Generate a research questions file in thoughts/ for a given task
---

# Research Questions

Given a task, generate a structured list of questions that `/research_codebase` should answer before planning can begin. The output is a file in `thoughts/` that can be passed directly to `/research_codebase` as the starting point for a research session.

## Input

A task file path (e.g. `tasks/TASK-001.md`) or a description of what needs to be built.

If no input is provided, ask:

```
Which task would you like to generate research questions for?
Provide a task file path (e.g. tasks/TASK-001.md) or describe what needs to be built.
```

## Process

### 1. Read the task

Read the task file fully. Also read any documents listed in its `## Links` section.

If a task file was not provided, work from the description given.

### 2. Think deeply about what is unknown

Before writing questions, reason through the task:

- What does this feature touch? (data model, API, UI, infra, config?)
- What existing code will need to change or be understood?
- What behaviour does the codebase currently have that is relevant?
- What constraints or patterns must be followed?
- What could go wrong, and what would a researcher need to know to avoid it?
- Are there integration points with other systems that need mapping?

Think like someone who will be handed the research doc and asked to write an implementation plan. What would they need to know?

### 3. Write the research questions file

Run `bash opencode/scripts/spec_metadata.sh` to get metadata.

Save to:
- **If `thoughts/` exists:** `thoughts/shared/research/YYYY-MM-DD-TASK-XXX-research-questions.md`
- **Otherwise:** `/tmp/research/YYYY-MM-DD-TASK-XXX-research-questions.md`

Use this structure:

```markdown
---
date: [ISO datetime with timezone]
git_commit: [current commit hash]
branch: [current branch]
repository: [repo name]
task: "[task ID and title]"
type: research-questions
---

# Research Questions: [Task Title]

## Context

[2-3 sentences summarising the task — what needs to be built and why, based on the task file.]

## Questions

### Understanding Current Behaviour

[Questions about what the codebase does today in the relevant area. These orient the researcher before diving into implementation concerns.]

- [e.g. How does X currently work? Where is it implemented?]
- [e.g. What data model backs Y? Where is it defined?]
- [e.g. What happens when Z is called — what is the full call chain?]

### Boundaries and Integration Points

[Questions about what the feature touches and how it connects to the rest of the system.]

- [e.g. Which services/modules will need to change?]
- [e.g. How does this interact with the auth/config/queue system?]
- [e.g. Are there existing hooks or extension points that could be used?]

### Patterns and Conventions

[Questions to ensure the implementation follows existing conventions rather than inventing new ones.]

- [e.g. How is a similar feature implemented? What patterns should be followed?]
- [e.g. What testing patterns apply here?]
- [e.g. How are errors handled in this part of the codebase?]

### Constraints and Risks

[Questions about things that could go wrong or constrain the implementation.]

- [e.g. Are there performance constraints to be aware of?]
- [e.g. Is there existing state or data that migration logic must handle?]
- [e.g. Are there dependencies or external services that affect this?]

## Suggested Research Approach

[Brief note on which parts of the codebase to focus on first, and any specific files or directories the researcher should start with, based on your understanding of the task.]
```

### 4. Sync and link

- **If `thoughts/` exists:** run `bash opencode/scripts/thoughts_sync.sh`
- Add the file path to the task's `## Links` section

### 5. Report

```
✅ Research questions created for [task ID]: [task title]

File: [path to questions file]

[N] questions across [M] categories:
- Understanding Current Behaviour ([N] questions)
- Boundaries and Integration Points ([N] questions)
- Patterns and Conventions ([N] questions)
- Constraints and Risks ([N] questions)

Pass this file to /research_codebase to begin investigation.
```
