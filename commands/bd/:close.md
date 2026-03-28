Close task with reason.

## Usage

```bash
/bd:close <task-id> --reason "..."
```

## Options

- `--reason` - Reason for closing (required)
- `-m, --message` - Add closing comment

## Examples

```bash
/bd:close bd-abc123 --reason "Completed"
/bd:close bd-abc123 --reason "Duplicate" -m "Merged into bd-def456"
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd close $ARGUMENTS`
