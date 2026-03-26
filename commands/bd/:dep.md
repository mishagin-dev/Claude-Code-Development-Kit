Manage dependencies between tasks.

## Usage

```bash
/bd:dep <action> [args]
```

## Actions

- `add <child> <parent>` - Add dependency (child blocks parent)
- `remove <child> <parent>` - Remove dependency
- `tree <issue-id>` - Show dependency tree

## Dependency Types

When adding dependencies, specify the relationship:

- `blocks` - Child blocks parent (default)
- `parent-child` - Hierarchical relationship
- `related` - Loose association
- `discovered-from` - Side quest origin task

## Example

```bash
# Add blocking dependency
/bd:dep add bd-child123 bd-parent456

# Show dependency tree
/bd:dep tree bd-epic789

# Remove dependency
/bd:dep remove bd-child123 bd-parent456
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd dep $ARGUMENTS`
