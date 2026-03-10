---
description: Create worktree and launch implementation session for a plan
---

# Create Worktree and Launch Implementation

1. set up worktree for implementation:
   1a. use the `worktree_create` tool to create a new worktree with the Linear branch name

2. determine required data:

branch name
path to plan file (use relative path only)
launch prompt
command to run

**IMPORTANT PATH USAGE:**

- The thoughts/ directory is synced between the main repo and worktrees
- Always use ONLY the relative path starting with `thoughts/shared/...` without any directory prefix
- Example: `thoughts/shared/plans/fix-mcp-keepalive-proper.md` (not the full absolute path)
- This works because thoughts are synced and accessible from the worktree

2a. confirm with the user by sending a message to the Human

```
Based on the input, I plan to create a worktree with the following details:

worktree path: ~/wt/<repo>/ENG-XXXX
branch name: BRANCH_NAME
path to plan file: $FILEPATH

To launch the implementation session, run in your terminal:

tmux new-window -n "ENG-XXXX" -c "~/wt/<repo>/ENG-XXXX" "opencode -m anthropic/claude-opus-4-6"

Then in OpenCode, run:
/implement_plan $FILEPATH

After implementation and tests pass:
/commit
/describe_pr

Then add a comment to the Linear ticket with the PR link.
```

For faster iteration with relaxed permissions:

```
tmux new-window -n "ENG-XXXX" -c "~/wt/<repo>/ENG-XXXX" "opencode -m anthropic/claude-opus-4-6 -p allow"
```

incorporate any user feedback then:

3. Create the worktree using the `worktree_create` tool and provide the launch instructions above.
