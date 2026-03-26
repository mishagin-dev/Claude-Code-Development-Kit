List tasks that are ready to work on (no open blockers).

## Usage

```bash
/bd:ready [options]
```

## Options

- `--json` - JSON output for programmatic use
- `--limit N` - Limit number of results
- `--assigned-to-me` - Only tasks assigned to you

## Example

```bash
/bd:ready
/bd:ready --json
/bd:ready --limit 5 --assigned-to-me
```

## Auto-Loaded Context

@/workflow/ai-context/project-structure.md

---

Execute: `bd ready $ARGUMENTS`
