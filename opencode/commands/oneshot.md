---
description: Research ticket and launch planning session
---

1. Read `opencode/commands/ralph_research.md` and follow all of its instructions for the given ticket number.

2. Once research is complete, provide instructions for launching a new planning session:

```
To launch the planning session, run in your terminal:

tmux new-window -n "plan ENG-XXXX" -c "$(pwd)" "opencode -m anthropic/claude-opus-4-6"

Then in OpenCode, run:
/oneshot_plan ENG-XXXX
```

Alternatively, if you want to run with relaxed permissions (auto-approve edits):

```
tmux new-window -n "plan ENG-XXXX" -c "$(pwd)" "opencode -m anthropic/claude-opus-4-6 -p allow"
```
