---
description: Launch a new OpenCode session in a separate tmux window for parallel work
---

# Launch Session

Creates instructions for launching a new OpenCode session in a tmux window. Since OpenCode cannot directly control tmux, this command generates the commands for you to run.

## Usage

Provide:

- Working directory (absolute path or relative to current worktree)
- Session name/title (for the tmux window)
- Initial command to run in OpenCode (optional)
- Model preference (optional, defaults to sonnet)

## Process

1. **Gather information**:
   - Determine working directory (use worktree path if relative)
   - Generate a meaningful tmux window name
   - Format the initial command if provided

2. **Generate launch commands**:

   For a simple session:

   ```bash
   tmux new-window -n "SESSION_NAME" -c "WORKDIR" "opencode"
   ```

   For a session with an initial command:

   ```bash
   tmux new-window -n "SESSION_NAME" -c "WORKDIR" "opencode run 'INITIAL_COMMAND'"
   ```

   For a session with a specific model:

   ```bash
   tmux new-window -n "SESSION_NAME" -c "WORKDIR" "opencode -m MODEL"
   ```

3. **Present to user**:

   ```
   To launch this session, run in your terminal:

   tmux new-window -n "ENG-XXXX" -c "~/wt/project/ENG-XXXX" "opencode"

   Then in OpenCode, run:
   /implement_plan thoughts/shared/plans/...

   Alternatively, run everything in one command:
   tmux new-window -n "ENG-XXXX" -c "~/wt/project/ENG-XXXX" "opencode run '/implement_plan ...'"
   ```

## Examples

### Launch implementation session in a worktree

```
/launch_session ~/wt/project/ENG-1234 "implement ENG-1234" "/implement_plan thoughts/shared/plans/2025-01-08-ENG-1234-feature.md"
```

Output:

```
tmux new-window -n "implement ENG-1234" -c "~/wt/project/ENG-1234" "opencode"

Then run: /implement_plan thoughts/shared/plans/2025-01-08-ENG-1234-feature.md
```

### Launch research session

```
/launch_session . "research" "/research_codebase authentication flow"
```

### Launch with specific model

```
/launch_session ~/wt/project/ENG-5678 "plan ENG-5678" "/create_plan" opus
```

Output:

```
tmux new-window -n "plan ENG-5678" -c "~/wt/project/ENG-5678" "opencode -m anthropic/claude-opus-4-6"
```

## Worktree Integration

This command works well with git worktrees for parallel development:

```bash
# Create worktree first
git worktree add -b ENG-1234 ~/wt/project/ENG-1234 origin/main

# Then launch session
/launch_session ~/wt/project/ENG-1234 "ENG-1234" "/implement_plan ..."
```

## Model Shortcuts

When specifying a model, you can use shortcuts:

- `opus` → `anthropic/claude-opus-4-6`
- `sonnet` → `anthropic/claude-sonnet-4-6`
- `haiku` → `anthropic/claude-haiku-4-5`
- Or specify the full model name

## Notes

- Sessions launched this way are independent OpenCode instances
- Each session has its own conversation history
- Use `/share` in each session to share conversation links
- Sessions persist in tmux even if you detach
