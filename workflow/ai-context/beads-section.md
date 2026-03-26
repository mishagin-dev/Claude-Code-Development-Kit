
## 7. Task Management with Beads

### When to Use Beads
- Multi-session work spanning days or weeks
- Tasks with blockers and dependencies
- Side quests discovered during main work
- Project memory that survives context compaction

### When to Use TodoWrite Instead
- Single-session tasks
- Linear execution without branching
- Simple checklists

### Automatic Session Integration
- Session start hook checks for ready tasks
- If tasks available, you'll see a summary
- Run `/bd:work` to claim and execute a task

### Workflow
1. Check ready tasks: `/bd:ready`
2. Work on task: `/bd:work`
3. Create tasks: `/bd:create "description"`
4. Close tasks: `/bd:close <id> --reason "..."`

### Best Practices
- Claim before work: `bd update <id> --claim`
- Atomic commits: One task = one logical change
- Close with context: Reason should summarize what was done

See `.claude/commands/bd/README.md` for full command reference.
