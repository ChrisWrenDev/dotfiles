---
description: Debug issues by investigating logs, git state, and environment
---

# Debug

You are tasked with helping debug issues during manual testing or implementation. This command allows you to investigate problems by examining git state, environment, and running diagnostic commands.

## Initial Response

When invoked WITH a plan/ticket file:

```
I'll help debug issues with [file name]. Let me understand the current state.

What specific problem are you encountering?
- What were you trying to test/implement?
- What went wrong?
- Any error messages?

I'll investigate the logs, git state, and environment to help figure out what's happening.
```

When invoked WITHOUT parameters:

```
I'll help debug your current issue.

Please describe what's going wrong:
- What are you working on?
- What specific problem occurred?
- When did it last work?

I can investigate git state, recent changes, and run diagnostics to help identify the issue.
```

## Environment Information

You have access to these key tools and locations:

**Git State**:

- Check current branch, recent commits, uncommitted changes
- View diff of recent modifications
- Check worktree status

**Build/Test Output**:

- Run `make check` or `make test` to see failures
- Check for compilation errors
- View test output

**Process State**:

- Check if services are running: `ps aux | grep <service>`
- Check network ports: `lsof -i :<port>` or `ss -tlnp`

**Logs** (project-specific):

- Check common log locations based on project type
- Look for error patterns in recent output

## Process Steps

### Step 1: Understand the Problem

After the user describes the issue:

1. **Read any provided context** (plan or ticket file):
   - Understand what they're implementing/testing
   - Note which phase or step they're on
   - Identify expected vs actual behavior

2. **Quick state check**:
   - Current git branch and recent commits
   - Any uncommitted changes
   - When the issue started occurring

### Step 2: Investigate the Issue

Spawn parallel Task agents for efficient investigation:

```
Task 1 - Check Git State:
Understand what changed recently:
1. Check git status and current branch
2. Look at recent commits: git log --oneline -10
3. Check uncommitted changes: git diff
4. Verify expected files exist
5. Look for any file permission issues
Return: Git state and any file issues
```

```
Task 2 - Run Build/Test:
Check if build and tests pass:
1. Run the project's check/lint command (e.g., make check, npm run lint)
2. Run the project's test command (e.g., make test, npm test)
3. Note any failures or errors
4. Check for type errors if TypeScript
Return: Build/test results and any failures
```

```
Task 3 - Check Environment:
Verify environment is set up correctly:
1. Check for required environment variables
2. Verify dependencies are installed
3. Check service status if applicable
4. Look for configuration issues
Return: Environment status and any issues
```

### Step 3: Present Findings

Based on the investigation, present a focused debug report:

````markdown
## Debug Report

### What's Wrong

[Clear statement of the issue based on evidence]

### Evidence Found

**From Git**:

- [Recent changes that might be related]
- [File state issues]

**From Build/Test**:

- [Error messages or failures]
- [Test results]

**From Environment**:

- [Configuration issues]
- [Missing dependencies]

### Root Cause

[Most likely explanation based on evidence]

### Suggested Fix

1. **Try This First**:
   ```bash
   [Specific command or action]
   ```
````

2. **If That Doesn't Work**:
   - [Alternative approach]
   - [Additional debugging steps]

### Can't Access?

Some issues might be outside my reach:

- Browser console errors (F12 in browser)
- External service logs
- System-level issues

Would you like me to investigate something specific further?

````

## Important Notes

- **Focus on the problem at hand** - This is for debugging during implementation
- **Always require problem description** - Can't debug without knowing what's wrong
- **Read files completely** - No limit/offset when reading context
- **Guide back to user** - Some issues (browser console, external services) are outside reach
- **No file editing** - Pure investigation only

## Quick Reference

**Git State**:
```bash
git status
git log --oneline -10
git diff
git branch -vv
````

**Build Check**:

```bash
make check        # or npm run lint, etc.
make test         # or npm test, etc.
make build        # or npm run build, etc.
```

**Process Check**:

```bash
ps aux | grep <process>
lsof -i :<port>
```

**Environment**:

```bash
env | grep <PREFIX>
cat .env.example
```

Remember: This command helps you investigate without burning the primary window's context. Perfect for when you hit an issue during manual testing and need to dig into git state, build output, or environment.
