import { tool } from '@opencode-ai/plugin'

export default tool({
	description: 'Collect repository and thoughts metadata for research, plans, and handoffs.',
	args: {},
	async execute(_args, context) {
		try {
			const cwd = context.worktree || context.directory
			const datetimeTz = await Bun.$`date '+%Y-%m-%d %H:%M:%S %Z'`.cwd(cwd).text()
			const filenameTs = await Bun.$`date '+%Y-%m-%d_%H-%M-%S'`.cwd(cwd).text()

			let repoName = ''
			let gitBranch = ''
			let gitCommit = ''

			try {
				repoName = (await Bun.$`basename $(git rev-parse --show-toplevel)`.cwd(cwd).text()).trim()
				gitBranch = (
					await Bun.$`git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD`
						.cwd(cwd)
						.text()
				).trim()
				gitCommit = (await Bun.$`git rev-parse HEAD`.cwd(cwd).text()).trim()
			} catch {}

			let thoughtsStatus = ''
			try {
				const thoughtsDir = `${cwd}/thoughts`
				const exists = (await Bun.$`test -d ${thoughtsDir} && echo exists`.text()).trim()
				if (exists) {
					const branch = (
						await Bun.$`git -C ${thoughtsDir} branch --show-current 2>/dev/null || true`.text()
					).trim()
					const status = (await Bun.$`git -C ${thoughtsDir} status --short 2>/dev/null || true`.text()).trim()
					thoughtsStatus = `Thoughts Branch: ${branch || 'unknown'}`
					if (status) thoughtsStatus += `\nThoughts Changes:\n${status}`
				}
			} catch {}

			const lines = [
				`Current Date/Time (TZ): ${datetimeTz.trim()}`,
				gitCommit ? `Current Git Commit Hash: ${gitCommit}` : '',
				gitBranch ? `Current Branch Name: ${gitBranch}` : '',
				repoName ? `Repository Name: ${repoName}` : '',
				`Timestamp For Filename: ${filenameTs.trim()}`,
				thoughtsStatus,
			].filter(Boolean)

			return lines.join('\n')
		} catch (error) {
			return `Error collecting metadata: ${error}`
		}
	},
})
