Create a new task.

## Usage

```bash
/bd:create "Title" [options]
```

## Options

- `-t, --type` - Task type (task, bug, feature, epic, chore)
- `-p, --priority` - Priority level (0-4, 0=critical)
- `--deps` - Dependencies (e.g., `blocks:bd-abc`, `discovered-from:bd-xyz`)
- `--json` - JSON output

## Example

```bash
/bd:create "Fix auth bug in login flow"
/bd:create "Add dark mode support" -t feature -p 2
/bd:create "Side quest from review" --deps discovered-from:bd-xyz123
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd create "$ARGUMENTS"`
