Find and claim a ready task, then work on it.

## Usage

```bash
/bd:work [task-id]
```

## What It Does

1. Lists ready tasks (if no ID provided)
2. Claims the selected task atomically
3. Shows task details
4. You do the work
5. Close with `/bd:close <id> --reason "..."`

## Examples

```bash
/bd:work              # List and select from ready tasks
/bd:work bd-abc123    # Claim specific task
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd ready && bd update $ARGUMENTS --claim && bd show $ARGUMENTS`
