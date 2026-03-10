import { tool } from '@opencode-ai/plugin'
import path from 'path'

/**
 * Sync the thoughts directory to the remote repository.
 * Equivalent to: cd thoughts && git add -A && git commit -m "sync" && git push
 */
export const sync = tool({
	description:
		'Sync the thoughts directory to the remote repository. Stages all changes, commits with a timestamp message, and pushes to remote.',
	args: {
		message: tool.schema
			.string()
			.optional()
			.describe("Optional commit message. Defaults to 'sync: YYYY-MM-DD_HH-MM-SS'"),
	},
	async execute(args, context) {
		const thoughtsDir = path.join(context.worktree || context.directory, 'thoughts')
		const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
		const commitMessage = args.message || `sync: ${timestamp}`

		try {
			// Check if thoughts directory exists
			const dirCheck = await Bun.$`test -d ${thoughtsDir} && echo "exists"`.text()
			if (!dirCheck.trim()) {
				return 'Error: thoughts/ directory does not exist. Run thoughts_init first.'
			}

			// Check if it's a git repo
			const gitCheck = await Bun.$`git -C ${thoughtsDir} rev-parse --git-dir 2>/dev/null`.text()
			if (!gitCheck.trim()) {
				return 'Error: thoughts/ is not a git repository. Run thoughts_init first.'
			}

			// Stage all changes
			await Bun.$`git -C ${thoughtsDir} add -A`

			// Check if there are changes to commit
			const status = await Bun.$`git -C ${thoughtsDir} status --porcelain`.text()
			if (!status.trim()) {
				return 'No changes to sync in thoughts directory.'
			}

			// Commit
			await Bun.$`git -C ${thoughtsDir} commit -m ${commitMessage}`

			// Push
			const pushResult = await Bun.$`git -C ${thoughtsDir} push 2>&1`.text()

			return `Thoughts synced successfully.\nCommit: ${commitMessage}\n${pushResult}`
		} catch (error) {
			return `Error syncing thoughts: ${error}`
		}
	},
})

/**
 * Initialize the thoughts directory.
 * Clones the thoughts repository or sets up the directory structure.
 */
export const init = tool({
	description:
		'Initialize the thoughts directory for the project. Clones from a remote repository or creates the directory structure.',
	args: {
		repository: tool.schema
			.string()
			.optional()
			.describe('Git repository URL to clone. If not provided, creates an empty thoughts structure.'),
		directory: tool.schema
			.string()
			.optional()
			.describe('Optional subdirectory within the thoughts repo to use for repo-specific layouts.'),
	},
	async execute(args, context) {
		const thoughtsDir = path.join(context.worktree || context.directory, 'thoughts')

		try {
			// Check if thoughts already exists
			const exists = await Bun.$`test -d ${thoughtsDir} && echo "exists"`.text()
			if (exists.trim()) {
				return 'thoughts/ directory already exists. Delete it first if you want to reinitialize.'
			}

			if (args.repository) {
				// Clone the repository
				await Bun.$`git clone ${args.repository} ${thoughtsDir}`

				if (args.directory) {
					// If a subdirectory is specified, we need to set up sparse checkout or symlink
					return `Thoughts repository cloned. Note: subdirectory '${args.directory}' specified - you may need to configure your workflow to use thoughts/repos/${args.directory}/ as the root.`
				}

				return `Thoughts repository cloned successfully to ${thoughtsDir}`
			} else {
				// Create empty structure
				await Bun.$`mkdir -p ${thoughtsDir}/shared/research`
				await Bun.$`mkdir -p ${thoughtsDir}/shared/plans`
				await Bun.$`mkdir -p ${thoughtsDir}/shared/tickets`
				await Bun.$`mkdir -p ${thoughtsDir}/shared/prs`
				await Bun.$`mkdir -p ${thoughtsDir}/shared/handoffs`

				// Initialize git repo
				await Bun.$`git -C ${thoughtsDir} init`

				// Create .gitkeep files
				await Bun.$`touch ${thoughtsDir}/shared/research/.gitkeep`
				await Bun.$`touch ${thoughtsDir}/shared/plans/.gitkeep`
				await Bun.$`touch ${thoughtsDir}/shared/tickets/.gitkeep`
				await Bun.$`touch ${thoughtsDir}/shared/prs/.gitkeep`
				await Bun.$`touch ${thoughtsDir}/shared/handoffs/.gitkeep`

				return `Thoughts directory initialized with empty structure at ${thoughtsDir}.\nRemember to add a remote: git -C thoughts remote add origin <url>`
			}
		} catch (error) {
			return `Error initializing thoughts: ${error}`
		}
	},
})

/**
 * Check the status of the thoughts directory.
 */
export const status = tool({
	description: 'Check the status of the thoughts directory - shows git status and sync state.',
	args: {},
	async execute(args, context) {
		const thoughtsDir = path.join(context.worktree || context.directory, 'thoughts')

		try {
			// Check if thoughts directory exists
			const exists = await Bun.$`test -d ${thoughtsDir} && echo "exists"`.text()
			if (!exists.trim()) {
				return 'thoughts/ directory does not exist. Run thoughts_init to create it.'
			}

			// Check if it's a git repo
			const gitCheck = await Bun.$`git -C ${thoughtsDir} rev-parse --git-dir 2>/dev/null`.text()
			if (!gitCheck.trim()) {
				return 'thoughts/ exists but is not a git repository.'
			}

			// Get current branch
			const branch = await Bun.$`git -C ${thoughtsDir} branch --show-current`.text()

			// Get status
			const status = await Bun.$`git -C ${thoughtsDir} status --short`.text()

			// Check if ahead/behind remote
			const trackingStatus = await Bun.$`git -C ${thoughtsDir} status -sb`.text()

			let result = `Thoughts directory: ${thoughtsDir}\n`
			result += `Branch: ${branch.trim()}\n`
			result += `\nTracking: ${trackingStatus.trim().split('\n')[0]}\n`

			if (status.trim()) {
				result += `\nUncommitted changes:\n${status}`
			} else {
				result += `\nNo uncommitted changes.`
			}

			return result
		} catch (error) {
			return `Error checking thoughts status: ${error}`
		}
	},
})
