---
description: Implement highest priority small Linear ticket with worktree setup
model: sonnet
---

## PART I - IF A TICKET IS MENTIONED

0c. use `linear` cli to fetch the selected item into thoughts with the ticket number - ./thoughts/shared/tickets/ENG-xxxx.md
0d. read the ticket and all comments to understand the implementation plan and any concerns

## PART I - IF NO TICKET IS MENTIONED

0.  read opencode/commands/linear.md
    0a. fetch the top 10 priority items from linear in status "ready for dev" using the MCP tools, noting all items in the `links` section
    0b. select the highest priority SMALL or XS issue from the list (if no SMALL or XS issues exist, EXIT IMMEDIATELY and inform the user)
    0c. use `linear` cli to fetch the selected item into thoughts with the ticket number - ./thoughts/shared/tickets/ENG-xxxx.md
    0d. read the ticket and all comments to understand the implementation plan and any concerns

## PART II - NEXT STEPS

think deeply

1. move the item to "in dev" using the MCP tools
   1a. identify the linked implementation plan document from the `links` section
   1b. if no plan exists, move the ticket back to "ready for spec" and EXIT with an explanation

think deeply about the implementation

2. set up worktree for implementation:
   2a. use the `worktree_create` tool to create a new worktree with the Linear branch name

2b. Provide instructions for launching the implementation session:

```
To launch the implementation session, run in your terminal:

tmux new-window -n "implement ENG-XXXX" -c "~/wt/<repo>/ENG-XXXX" "opencode -m anthropic/claude-opus-4-6"

Then in OpenCode, run:
/implement_plan [path-to-plan]

After implementation completes and tests pass:
/commit
/describe_pr

Then add a comment to the Linear ticket with the PR link.
```

Alternatively, with relaxed permissions for faster iteration:

```
tmux new-window -n "implement ENG-XXXX" -c "~/wt/<repo>/ENG-XXXX" "opencode -m anthropic/claude-opus-4-6 -p allow"
```

think deeply, use TodoWrite to track your tasks. When fetching from linear, get the top 10 items by priority but only work on ONE item - specifically the highest priority SMALL or XS sized issue.
