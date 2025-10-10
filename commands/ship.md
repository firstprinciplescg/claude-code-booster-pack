# ship

Commit all changes and push to GitHub with a meaningful commit message.

## Steps

1. **Pre-flight checks** (for Node.js projects):
   - If `package.json` exists, run `npm run lint` to catch ESLint errors
   - If lint fails, stop and fix errors before proceeding
   - This prevents build failures in CI/CD (Vercel, GitHub Actions, etc.)
2. Run `git status` to check for changes
3. Run `git diff --staged --stat` to see what will be committed
4. Run `git log --oneline -5` to review recent commit message style
5. Stage all changes with `git add .`
6. Create a commit with a descriptive message following this format:
   - Concise summary line (50 chars or less)
   - Blank line
   - Bullet points describing changes (if needed)
   - Footer with Claude Code attribution
7. Push to remote with `git push`

## Commit Message Format

```
<type>: <concise summary>

- <change description>
- <change description>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Pre-flight Checks

For **Node.js projects** (has `package.json`):
- **Always run** `npm run lint` before committing
- If lint passes, proceed with commit
- If lint fails, fix errors and re-run `/ship`

This catches errors **before** they reach Vercel/CI, preventing failed deployments.

## Notes

- Analyze the git diff to create an accurate, meaningful commit message
- Group related changes logically in the commit message
- Use appropriate commit type prefixes (feat, fix, docs, refactor, etc.)
- Keep the summary line under 50 characters
- Focus on "why" not just "what" in descriptions
- Pre-flight checks are non-negotiable for production deployments
