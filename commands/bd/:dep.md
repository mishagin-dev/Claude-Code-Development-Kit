Manage dependencies between tasks.

## Usage

```bash
/bd:dep <command> [options]
```

## Commands

- `add <child> <parent>` - Add dependency (child blocks parent)
- `remove <child> <parent>` - Remove dependency
- `tree <task-id>` - Show dependency tree

## Dependency Types

- `blocks` - Blocks execution (default)
- `discovered-from` - Found during work on another task
- `related-to` - Related but not blocking

## Examples

```bash
/bd:dep add bd-child bd-parent
/bd:dep add bd-bug bd-feature --type discovered-from
/bd:dep tree bd-epic123
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd dep $ARGUMENTS`
