---
description: Create focused git commits with clear, atomic messages
---

# Commit Changes

## Process

1. **Understand what changed:**
   - Review the conversation history
   - Run `git status` and `git diff`
   - Decide whether changes warrant one commit or multiple logical commits

2. **Plan commits:**
   - Group related files together
   - Write commit messages in imperative mood focused on *why*, not just *what*
   - Never commit the `thoughts/` directory or anything inside it
   - Never commit generated files, temp scripts, or files unrelated to the session's changes

3. **If running unattended (e.g. called from an automated flow):** execute immediately.

   **Otherwise:** present the plan first:
   ```
   I plan to create [N] commit(s):

   Commit 1: [message]
     Files: [list]

   Shall I proceed?
   ```

4. **Execute:**
   - `git add` with specific file names — never `-A` or `.`
   - `git commit -m "[message]"` — no Claude attribution, no co-author lines
   - Show result with `git log --oneline -n [N]`

## Rules

- **No Claude attribution** — commits are authored solely by the user; no "Generated with Claude" or "Co-Authored-By" lines
- Keep commits atomic and focused
- You have full session context — use it
