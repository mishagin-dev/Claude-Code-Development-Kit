
## 7. Task Management with Beads

Use 'bd' for task tracking across sessions.

**When to use:**
- Multi-session work spanning days or weeks
- Tasks with blockers and dependencies
- Side quests discovered during main work
- Project memory that survives context compaction

**Quick start:**
- `/bd:work` — find and claim a ready task
- `/bd:create "description"` — create new task
- `/bd:close <id> --reason "..."` — close completed task

**Automatic Context Injection:**
- Session start hook checks for ready tasks and shows summary
- Sub-agent context injector includes `workflow/addons/BEADS.md`
- This ensures all sub-agents understand the task tracking workflow

Full documentation: @workflow/addons/BEADS.md
