---
description: Analyze and optimize Claude Code configuration
---

# Claude Code Configuration Cleanup

This command performs a comprehensive analysis of your Claude Code setup.

## Pre-Analysis Checks

First, let's verify the current state of your configuration:

1. Check Git status in ~/.claude/ to ensure changes are committed
2. List recently modified agents and commands
3. Identify active projects (sessions modified in last 30 days)

Now, use the Task tool to launch the ClaudeCodeCleanup agent to perform a comprehensive analysis of my Claude Code configuration. The agent should:

1. Scan both global (~/.claude/) and project-specific (.claude/) configurations
2. Analyze agents, commands, CLAUDE.md files, MCPs, and rules
3. Identify duplicates, scope mismatches, orphaned files, and optimization opportunities
4. Provide a detailed report with prioritized recommendations
5. Include specific file paths and actionable cleanup steps

Provide the full analysis report with critical issues, recommended improvements, and a detailed action plan.
