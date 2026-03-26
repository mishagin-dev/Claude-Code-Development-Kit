You are working on the current project. The user has requested to implement a feature, enhancement, or bug fix described in their arguments: "$ARGUMENTS"

## Auto-Loaded Project Context:

@/CLAUDE.md
@/workflow/ai-context/project-structure.md
@/workflow/ai-context/docs-overview.md

## Step 1: Parse Request and Gather Context

Analyze the user's input "$ARGUMENTS" to extract:

1. **Tagged files**: Extract all `@` tagged file paths (design docs, specs, examples, existing code)
2. **Natural language description**: Parse the feature/enhancement/fix description
3. **Provided documents**: If user provided design documents, specs, or examples - read and analyze them thoroughly to extract requirements, constraints, and expected behavior

For each tagged file:

- **Verify file exists** - If not found, inform user and ask for correction
- **Read file contents** - Understand structure, purpose, and relevant patterns
- **Identify document type** - Spec, example code, design doc, test file, etc.

**Read relevant project documentation** using `/workflow/ai-context/docs-overview.md` to route to the appropriate docs for the area being implemented.

**CRITICAL: If the request is ambiguous, underspecified, or could be interpreted multiple ways - STOP and ask the user for clarification. Never guess at requirements.**

## Step 2: Scope Assessment and Strategy Selection

Based on the parsed request and gathered context, intelligently decide the optimal implementation approach. Consider the complexity of the task, how many domains it touches, and
whether established patterns exist to follow.

### Strategy Tiers:

**Direct Implementation** (0-1 sub-agents):

- When the task can be handled efficiently with the context already gathered
- Clear, established patterns to follow with straightforward application
- Simple feature additions, bug fixes, or single-component changes

**Focused Implementation** (2-3 sub-agents):

- When deep research into a specific area would improve the implementation
- Single-domain tasks that require thorough exploration of patterns, dependencies, or integration points
- Established patterns exist but require adaptation or careful dependency mapping

**Comprehensive Implementation** (3+ sub-agents):

- When the task involves multiple areas, components, or technical domains
- When thorough understanding from different perspectives is needed before building
- Novel patterns, significant architectural additions, or extensive cross-component impact
- Scale the number of agents based on actual complexity, not predetermined patterns

## Step 3: Research and Analysis (Sub-Agent Phase)

### If prior analysis is available (e.g., from `/full-context`):

Use the existing findings as the research foundation. Skip to Step 4. Only launch targeted sub-agents if the prior analysis has clear gaps for the specific implementation needs (e.g., missing test patterns, missing dependency mapping for a specific file, or unexplored integration points).

### For Direct Implementation:

Skip to Step 4. Use the initial context gathered in Step 1.

### For Focused and Comprehensive Implementation (no prior analysis):

Launch parallel sub-agents to build a thorough understanding before planning. Design agents based on the specific implementation needs - the following are key investigation areas
to consider:

**Core Investigation Areas:**

- **Codebase pattern analysis**: Find reference implementations of similar features, understand conventions
- **Dependency and impact mapping**: Trace imports/exports, identify all files affected by the change
- **Integration point analysis**: Understand APIs, contracts, and boundaries the implementation must respect
- **Test pattern discovery**: Find existing test patterns, fixtures, and utilities to follow
- **Technology research** (when needed): Research libraries, APIs, or techniques relevant to the implementation

**Sub-Agent Task Template:**

```
Task: "Research [SPECIFIC_AREA] to inform implementation of [FEATURE] related to user request '$ARGUMENTS'"

Standard Investigation Workflow:
1. Review auto-loaded project context (CLAUDE.md, project-structure.md, docs-overview.md)
2. [CUSTOM_ANALYSIS_STEPS] - Investigate the specific area thoroughly
3. Find reference implementations and established patterns
4. Map dependencies, imports, and integration points
5. Identify risks and constraints

Return actionable findings: patterns to follow, files to reference, constraints to respect, and risks to mitigate."
```

**CRITICAL: When launching sub-agents, always use parallel execution with a single message containing multiple Task tool invocations.**

## Step 4: Create Implementation Plan

Write a structured implementation plan to `.claude/plan.md` with checkable items organized by phase. This file serves as external state for sub-agent coordination and context compression resilience.

### Plan Structure:

```markdown
# Implementation: [Feature Name]

## Summary

[1-2 sentence description of what's being implemented and why]

## Approach

[Brief description of the chosen strategy and key design decisions]

## Tasks

### Phase 1: Foundation

- [ ] [Task with explicit file path] - [Brief rationale]
- [ ] [Task with explicit file path] - [Brief rationale]

### Phase 2: Core Logic

- [ ] [Task with explicit file path] - [Brief rationale]

### Phase 3: Integration

- [ ] [Task with explicit file path] - [Brief rationale]

### Phase 4: Verification

- [ ] [Verification task] - [What it validates]

## Files to Create

- `path/to/new-file.ts` - [Purpose]

## Files to Modify

- `path/to/existing-file.ts` - [What changes and why]

## Dependencies

- [External dependency or prerequisite, if any]

## Risks

- [Identified risk] - [Mitigation strategy]
```

### Plan Quality Criteria:

- **Specific and actionable**: Each task describes exactly what to do
- **Explicit file paths**: Every task references concrete files
- **Logical ordering**: Dependencies flow naturally between phases
- **Minimal footprint**: Only touch files that genuinely need changes
- **Project conventions**: Follow established naming, structure, and patterns
- **Verification steps**: Include concrete checks for correctness

**Present the plan to the user and wait for approval before proceeding to implementation.**

## Step 5: Validate Plan with Gemini MCP (Optional)

If the Gemini MCP server is available, suggest plan validation to the user:

1. Ask if the user wants Gemini validation and their preferred model
2. Send the implementation plan for review, including:
  - The plan from Step 4
  - Relevant code context and patterns discovered in Step 3
  - Specific concerns or trade-offs identified
3. Evaluate Gemini feedback critically - not all suggestions warrant changes
4. If feedback reveals genuine issues, update the plan and re-present to the user

## Step 6: Execute Implementation

Follow the approved plan from `.claude/plan.md`, marking items complete (`[x]`) as you go.

### File Operations Order:

1. **Create directories** - Establish any new directory structure
2. **Create type definitions** - Interfaces, types, enums
3. **Create core logic** - Primary implementation files
4. **Create integration code** - Connectors, adapters, handlers
5. **Modify existing files** - Updates to existing code (imports, registrations, configurations)
6. **Update exports** - Barrel files, index files, public API surface

### Execution Guidelines:

- Provide a high-level summary after completing each phase
- Follow established project patterns and conventions strictly
- Maintain backward compatibility unless the plan explicitly breaks it
- Make every change as simple as possible. Impact minimal code

### Sub-Agent Execution (Focused/Comprehensive tiers):

For parallelizable implementation tasks, use sub-agents:

```
Task: "Implement [SPECIFIC_COMPONENT] for [FEATURE] following the approved plan.

Implementation context:
- Pattern reference: [file path to follow]
- Integration point: [where this connects]
- Conventions: [naming, structure rules]

Create/modify the specified files and ensure they follow project conventions."
```

**CRITICAL: If something goes wrong during implementation - a discovered constraint, unexpected complexity, or broken assumption - STOP. Return to Step 4, revise the plan, and
inform the user before continuing.**

## Step 7: Simplification Pass

After implementation is complete but before verification, run `/simplify` on all created and modified files to:

- Eliminate redundant code introduced across parallel sub-agent implementations
- Identify reuse opportunities with existing project utilities
- Reduce unnecessary complexity added during implementation
- Ensure the new code follows the project's efficiency patterns

This step is particularly valuable for **Focused and Comprehensive** strategy tiers where multiple sub-agents may produce overlapping or inconsistent patterns.

**Skip conditions:**

- **Direct Implementation** tier with trivial changes (< 50 lines across all files)
- User explicitly opted out during plan approval

## Step 8: Verification

### Automated Checks:

Run available project verification tools:

- **Type checking**: Run the project's type checker (e.g., `tsc --noEmit`, `mypy`)
- **Linting**: Run the project's linter (e.g., `eslint`, `ruff`)
- **Tests**: Run relevant test suites, including any new tests written
- **Build**: Verify the project builds successfully

### Behavioral Verification (Sub-Agent):

Launch a verification sub-agent:
```
Task: "Verify the implementation of [FEATURE] against the original requirements from '$ARGUMENTS'.

Verification checklist:
1. Read the original request and any provided specs/documents
2. Review all created and modified files
3. Verify each requirement is addressed
4. Check for missing edge cases or error handling
5. Confirm integration points work correctly
6. Validate that project conventions are followed

Report: requirements met, requirements missed, potential issues."
```

### Bug Fix Verification:

For bug fixes specifically, compare the implementation against the main branch:

- Review the diff to confirm the fix addresses the root cause
- Verify no regressions are introduced
- Check that the fix handles related edge cases

### Self-Challenge:

Before presenting results to the user, critically evaluate your own work:

- Does this actually solve the stated problem?
- Are there obvious failure modes not handled?
- Would a senior engineer approve this implementation?
- Did the simplification pass (Step 7) address all redundancy and complexity concerns?

## Step 9: Documentation

Trigger appropriate documentation updates based on what was implemented:

### New Functionality:

Launch a documentation sub-agent:

```
Task: "Run /create-docs for the newly implemented [FEATURE].
Focus on: [list of new files and their purposes]"
```

### Modified Existing Functionality:

Launch a documentation sub-agent:
```
Task: "Run /update-docs for the changes made to [MODIFIED_AREA].
Changes include: [summary of modifications]"
```

### Update Task Tracking:

Finalize the plan state:

- Mark all remaining tasks as complete in `.claude/plan.md`
- Add any notes about deviations from the plan
- Output the completion summary to the user in the chat
- Delete `.claude/plan.md` to clean up the workspace

## Error Handling

### Ambiguous Request

If the user's request is unclear or could be interpreted multiple ways, ask specific clarifying questions. Do not proceed with assumptions.

### File Not Found

If a tagged file doesn't exist, inform the user and ask for the correct path. Do not guess at alternatives.

### Conflicting Documents

If provided documents contain contradictory requirements, present the conflicts to the user and ask for resolution before planning.

### Plan Rejected

If the user rejects the plan, ask what aspects need revision. Revise and re-present. Do not proceed without approval.

### Gemini Concerns

If Gemini validation raises significant concerns, present them to the user with your assessment of whether the concerns are valid and how they affect the plan.

### Implementation Failure

If implementation hits an unexpected blocker, STOP. Return to Step 4, revise the plan with the new information, and present the revised plan to the user.

### Verification Failure

If automated checks fail (type errors, lint errors, test failures, build failures), fix the issues before presenting results. If fixes require plan changes, return to Step 4.

### Test Failures

If existing tests break, investigate root cause. Either fix the implementation to pass existing tests or, if the behavioral change is intentional, update the tests and document
why.

### Scope Creep

If during implementation you discover the feature requires significantly more work than planned, STOP. Present the expanded scope to the user and get approval before continuing.

## Summary Format

After completion, provide an implementation report:

```markdown
# Implementation Report: [Feature Name]

## Summary

[What was implemented and the approach taken]

## Files Created

- `path/to/file.ts` - [Purpose]

## Files Modified

- `path/to/file.ts` - [What changed]

## Design Decisions

- [Decision] - [Rationale]

## Verification Results

- Type checking: [Pass/Fail]
- Linting: [Pass/Fail]
- Tests: [Pass/Fail - X passed, Y added]
- Build: [Pass/Fail]
- Behavioral verification: [Summary]

## Documentation Updates
- [What docs were created or updated]

## Known Limitations

- [Any limitations or future work items]
```

### Follow-up Actions:

Offer relevant next steps:

- "Would you like me to run `/code-review` on the implementation?"
- "Should I add more test coverage for edge cases?"
- "Would you like to run `/handoff` to preserve this context?"

Now proceed with plan-first implementation of: $ARGUMENTS