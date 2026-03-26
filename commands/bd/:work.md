Start working on a ready task from beads.

## Workflow

1. List ready tasks with `bd ready`
2. Ask user which task to work on (or take first if only one)
3. Claim the task: `bd update <id> --claim`
4. Read task details: `bd show <id>`
5. Execute the task following CCDK patterns
6. Close when done: `bd close <id> --reason "..."`

## Usage

```bash
/bd:work [task-id]
```

If no task-id provided, shows ready tasks and asks which to work on.

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute workflow for ready beads task.
