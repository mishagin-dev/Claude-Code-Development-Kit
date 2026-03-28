Update task status and metadata.

## Usage

```bash
/bd:update <task-id> [options]
```

## Options

- `--claim` - Claim the task atomically
- `--status` - Set status: open, in-progress, blocked, done
- `--priority` - Update priority: 0-4
- `--note` - Add a note

## Examples

```bash
/bd:update bd-abc123 --claim
/bd:update bd-abc123 --status in-progress
/bd:update bd-abc123 --priority 1 --note "Started work"
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd update $ARGUMENTS`
