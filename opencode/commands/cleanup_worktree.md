---
description: Clean up a finished or abandoned worktree and optionally delete its branch
---

# Cleanup Worktree

Use the `worktree_cleanup` tool to remove a worktree after the work is merged, abandoned, or recreated elsewhere.

## Usage

Provide:

- worktree name
- whether to also delete the local branch

## Process

1. Confirm the target worktree name.
2. Check whether the worktree still has uncommitted changes or unmerged work.
3. If cleanup is still appropriate, use the `worktree_cleanup` tool.
4. Report exactly what was removed.

## Example

```
/cleanup_worktree ENG-1234
```

Expected action:

```
Use `worktree_cleanup` with:
- name: ENG-1234
- deleteBranch: false
```

To also delete the branch:

```
Use `worktree_cleanup` with:
- name: ENG-1234
- deleteBranch: true
```

## Notes

- This command is intended for local branches/worktrees created through your tmux + worktree workflow.
- If the worktree still contains valuable uncommitted work, stop and summarize the risk before cleanup.
