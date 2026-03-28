Create a new task.

## Usage

```bash
/bd:create "title" [options]
```

## Options

- `-t, --type` - Task type: task, bug, feature, epic, chore (default: task)
- `-p, --priority` - Priority: 0-4 (default: 2)
- `--claim` - Claim the task immediately

## Examples

```bash
/bd:create "Fix login bug"
/bd:create "Add dark mode" -t feature -p 1
/bd:create "Refactor API" -t chore --claim
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd create "$ARGUMENTS"`
