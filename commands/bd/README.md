# Beads Commands

Task tracking commands for multi-session work with dependencies.

## Commands

| Command | Description |
|---------|-------------|
| `/bd:ready` | List unblocked tasks ready to work on |
| `/bd:create` | Create new task |
| `/bd:show` | Show task details with dependencies |
| `/bd:update` | Update task status and metadata |
| `/bd:close` | Close task with reason |
| `/bd:dep` | Manage dependencies between tasks |

## When to Use

Use **beads** for:
- Multi-session work spanning days or weeks
- Tasks with blockers and dependencies
- Side quests discovered during main work
- Project memory that survives context compaction

Use **TodoWrite** for:
- Single-session tasks
- Linear execution without branching
- Simple checklists

## Prerequisites

Install the beads CLI:

```bash
# macOS
brew install beads

# Or via npm
npm install -g @beads/bd

# Initialize in project
cd your-project
bd init
```

## Documentation

- [Beads GitHub](https://github.com/steveyegge/beads)
- [Beads Documentation](https://beads.dev)
