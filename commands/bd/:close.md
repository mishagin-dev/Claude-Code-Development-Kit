Close a task with reason.

## Usage

```bash
/bd:close <issue-id> --reason "Reason for closing"
```

## Options

- `--reason` - Why the task was closed (required)
- `--json` - JSON output

## Example

```bash
/bd:close bd-abc123 --reason "Implemented with tests passing"
/bd:close bd-abc123 --reason "Superseded by bd-xyz789"
/bd:close bd-abc123 --reason "No longer needed per stakeholder"
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd close $ARGUMENTS`
