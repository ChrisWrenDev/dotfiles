---
description: Generate comprehensive PR descriptions following repository templates
---

# Generate PR Description

## Steps

### 1. Get the PR description template

- Check if `thoughts/shared/pr_description.md` exists. If so, read it.
- If not, use this built-in template:

  ```markdown
  ## What problem(s) was I solving?

  ## What user-facing changes did I ship?

  ## How I implemented it

  ## How to verify it

  ### Manual Testing

  ## Description for the changelog
  ```

### 2. Identify the PR

- Check current branch: `gh pr view --json url,number,title,state 2>/dev/null`
- If none found, list open PRs: `gh pr list --limit 10 --json number,title,headRefName,author`
- Ask the user which PR to describe if ambiguous.

### 3. Check for existing description

- **If `thoughts/` exists:** check `thoughts/shared/prs/{number}_description.md`
- **Otherwise:** check `/tmp/{repo_name}/prs/{number}_description.md`
- If found, read it and note you'll be updating it.

### 4. Gather PR information

- Full diff: `gh pr diff {number}`
  - If error about no default remote, instruct user to run `gh repo set-default`
- Commits: `gh pr view {number} --json commits`
- Base branch: `gh pr view {number} --json baseRefName`
- Metadata: `gh pr view {number} --json url,title,number,state`

### 5. Analyze thoroughly (ultrathink)

- Read the entire diff carefully
- Read any referenced files not shown in the diff
- Understand purpose and impact of each change
- Identify user-facing vs internal changes
- Look for breaking changes or migration requirements

### 6. Handle verification

For each checklist item in the template's "How to verify it" section:
- Run it if it's a command (`make check`, `npm test`, etc.) — mark `- [x]` if passes, `- [ ]` with note if fails
- Leave unchecked and note for user if manual testing is required

### 7. Generate the description

Fill out every section from the template. Be specific about problems solved. Focus on the "why" as much as the "what". Include breaking changes prominently.

### 8. Save and update

- **If `thoughts/` exists:** save to `thoughts/shared/prs/{number}_description.md`, then run `thoughts_sync`
- **Otherwise:** save to `/tmp/{repo_name}/prs/{number}_description.md`
- Update the PR: `gh pr edit {number} --body-file {saved_path}`
- Confirm success. Remind user of any unchecked manual verification steps.

## Notes

- Always read the local template — don't hardcode assumptions about sections
- Be thorough but concise — descriptions should be scannable
- If the PR touches multiple components, organize accordingly
