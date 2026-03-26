Update task status and metadata.

## Usage

```bash
/bd:update <issue-id> [options]
```

## Options

- `--claim` - Atomically claim task (sets assignee + in_progress)
- `--status` - Set status (open, in_progress, blocked, deferred, closed)
- `--title` - Update title
- `--description` - Update description
- `--notes` - Add notes to the task

## Example

```bash
/bd:update bd-abc123 --claim
/bd:update bd-abc123 --status blocked --notes "Waiting on API response"
/bd:update bd-abc123 --title "Updated task title"
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd update $ARGUMENTS`
