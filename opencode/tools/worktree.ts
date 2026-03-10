import { tool } from "@opencode-ai/plugin";

export const create = tool({
  description:
    "Create a git worktree using the repository's scripts/create_worktree.sh helper.",
  args: {
    name: tool.schema
      .string()
      .optional()
      .describe("Worktree/branch name. If omitted, the script generates one."),
    baseBranch: tool.schema
      .string()
      .optional()
      .describe("Base branch to create from. Defaults to the current branch."),
    noThoughts: tool.schema
      .boolean()
      .optional()
      .describe("Skip thoughts initialization during worktree creation."),
  },
  async execute(args, context) {
    try {
      const cwd = context.worktree || context.directory;
      const script = `${cwd}/scripts/create_worktree.sh`;
      const output =
        await Bun.$`bash ${script} ${args.noThoughts ? "--no-thoughts" : ""} ${args.name || ""} ${args.baseBranch || ""}`
          .cwd(cwd)
          .text();
      return output.trim();
    } catch (error) {
      return `Error creating worktree: ${error}`;
    }
  },
});

export const cleanup = tool({
  description:
    "Clean up a git worktree non-interactively and optionally delete its branch.",
  args: {
    name: tool.schema.string().describe("Worktree name to clean up."),
    deleteBranch: tool.schema
      .boolean()
      .optional()
      .describe("Delete the local branch after removing the worktree."),
  },
  async execute(args, context) {
    try {
      const cwd = context.worktree || context.directory;
      const repoName = (
        await Bun.$`basename $(git rev-parse --show-toplevel)`.cwd(cwd).text()
      ).trim();
      const worktreePath = `${process.env.HOME}/wt/${repoName}/${args.name}`;

      await Bun.$`git worktree remove --force ${worktreePath}`.cwd(cwd);
      await Bun.$`git worktree prune`.cwd(cwd);

      let result = `Removed worktree: ${worktreePath}`;
      if (args.deleteBranch) {
        await Bun.$`git branch -D ${args.name}`.cwd(cwd);
        result += `\nDeleted branch: ${args.name}`;
      }
      return result;
    } catch (error) {
      return `Error cleaning up worktree: ${error}`;
    }
  },
});
