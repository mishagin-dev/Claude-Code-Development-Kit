You are working on the current project. Your role is to perform deep analysis and build comprehensive understanding for the user's request "$ARGUMENTS". You are strictly an analysis and understanding command — you investigate, map dependencies, identify patterns, and deliver structured findings. You never make code changes. If the user needs code changes, recommend `/implement` after delivering your analysis.

## Auto-Loaded Project Context:
@/CLAUDE.md
@/workflow/ai-context/project-structure.md
@/workflow/ai-context/docs-overview.md

## Step 1: Intelligent Analysis Strategy Decision

Think deeply about the optimal approach based on the project context that has been autoloaded above. Based on the user's request "$ARGUMENTS" and the project structure/documentation overview, intelligently decide the optimal approach:

### Implementation Detection

Before choosing a strategy, evaluate whether the user's request is asking for code changes (building, fixing, refactoring, adding features) versus understanding (how does X work, why is Y slow, what are the dependencies of Z).

If the request involves code changes or building something:
- Inform the user that `/full-context` will provide analysis and understanding of the relevant systems
- Recommend that they follow up with `/implement` to execute the actual changes using the analysis as a foundation

### Strategy Options:

**Direct Approach** (0-1 sub-agents):
- When the request can be handled efficiently with targeted documentation reading and direct analysis
- Simple questions about existing code or straightforward investigations

**Focused Investigation** (2-3 sub-agents):
- When deep analysis of a specific area would benefit the response
- For complex single-domain questions requiring thorough exploration
- When dependencies and impacts need careful assessment

**Multi-Perspective Analysis** (3 or more sub-agents):
- When the request involves multiple areas, components, or technical domains
- When comprehensive understanding requires different analytical perspectives
- For investigations requiring careful dependency mapping and impact assessment
- Scale the number of agents based on actual complexity, not predetermined patterns

## Step 2: Autonomous Sub-Agent Design

### For Sub-Agent Approach:

You have complete freedom to design sub-agent tasks based on:

- **Project structure discovered** from the auto-loaded `/workflow/ai-context/project-structure.md` file tree
- **Documentation architecture** from the auto-loaded `/workflow/ai-context/docs-overview.md`
- **Specific user request requirements**
- **Your assessment** of what investigation approach would be most effective

**CRITICAL: When using sub-agents, always launch them in parallel using a single message with multiple Task tool invocations. Never launch sequentially.**

### Sub-Agent Autonomy Principles:

- **Custom Specialization**: Define agent focus areas based on the specific request and project structure
- **Flexible Scope**: Agents can analyze any combination of documentation, code files, and architectural patterns
- **Adaptive Coverage**: Ensure all relevant aspects of the user's request are covered without overlap
- **Documentation + Code**: Each agent should read relevant documentation files AND examine actual implementation code
- **Dependency Mapping**: Analyze import/export relationships and identify how components connect
- **Impact Assessment**: Evaluate how changes in one area would ripple across the codebase, including tests, configurations, and related components
- **Pattern Analysis**: Document existing project conventions for naming, structure, and architecture
- **Web Research**: Consider, optionally, deploying sub-agents for web searches when current best practices, security advisories, or external compatibility research would enhance the analysis

### Sub-Agent Task Design Template:

```
Task: "Analyze [SPECIFIC_COMPONENT(S)] for [ANALYSIS_OBJECTIVE] related to user request '$ARGUMENTS'"

Standard Investigation Workflow:
1. Review auto-loaded project context (CLAUDE.md, project-structure.md, docs-overview.md)
2. (Optionally) Read additional relevant documentation files for architectural context
3. Analyze actual code files in [COMPONENT(S)] for implementation details
4. Map import/export dependencies and identify how components interconnect
5. Assess impact on tests, configurations, and related components
6. Document existing patterns and conventions

Return comprehensive findings that address the user's request from this component perspective, including architectural insights, implementation details, dependency map, and observed patterns."
```

Example Usage:
```
Analysis Task: "Analyze web-dashboard audio processing components to understand current visualization capabilities and identify integration points for user request about understanding how waveform rendering works"
Architecture Task: "Analyze agents/tutor-server voice pipeline components to map the latency-critical path and identify bottlenecks for user request about understanding response time characteristics"
Cross-Component Task: "Analyze Socket.IO integration patterns across web-dashboard and tutor-server to map the real-time communication architecture for user request about understanding live transcription data flow, including event contracts and dependency relationships"
```

## Step 3: Execution and Synthesis

### For Sub-Agent Approach:

Think deeply about integrating findings from all investigation perspectives.

1. **Design and launch custom sub-agents** based on your strategic analysis
2. **Collect findings** from all successfully completed agents
3. **Synthesize comprehensive understanding** by combining all perspectives
4. **Handle partial failures** by working with available agent findings
5. **Produce analysis deliverable** — structured findings, not code changes (see Step 5)

### For Direct Approach:

1. **Load relevant documentation and code** based on request analysis
2. **Produce analysis deliverable** using targeted context (see Step 5)

## Step 4: Consider MCP Server Usage (Optional)

After gathering context, you may leverage MCP servers for complex technical questions as specified in the auto-loaded `/CLAUDE.md` Section 4:
- **Gemini Consultation**: Deep analysis of complex coding problems
- **Context7**: Up-to-date documentation for external libraries

## Step 5: Analysis Deliverable

After gathering context using your chosen approach, produce a structured analysis summary:

### Analysis Summary Structure:

1. **Findings** — What was discovered through investigation. Key facts about how the system works, what exists, and what the current state is.
2. **Architecture and Patterns** — How the relevant systems are structured. Design patterns in use, conventions followed, and architectural decisions observed.
3. **Dependency Map** — How components connect. Import/export relationships, integration points, data flow paths, and coupling between modules.
4. **Risks and Considerations** — Potential issues, technical debt, fragile areas, edge cases, and constraints that should be understood before making changes.
5. **Recommendations** — Actionable insights based on the analysis. If the user asked an analytical question, answer it directly. If the analysis reveals opportunities for improvement, note them.

### Implementation Handoff

If the analysis reveals that the user's request requires code changes (new features, bug fixes, refactoring, enhancements):

- Summarize what the analysis has established as context for implementation
- **Recommend running `/implement`** with the relevant context to execute the changes
- Highlight any critical findings from the analysis that should inform the implementation approach

Do not execute code changes — deliver the understanding and let `/implement` handle the building.

## Optimization Guidelines

- **Adaptive Decision-Making**: Choose the approach that best serves the specific user request
- **Efficient Resource Use**: Balance thoroughness with efficiency based on actual complexity
- **Comprehensive Coverage**: Ensure all aspects relevant to the user's request are addressed
- **Quality Synthesis**: Combine findings effectively to provide the most helpful analysis

This adaptive approach ensures optimal context gathering — from lightweight direct analysis for simple requests to comprehensive multi-agent investigation for complex system-wide questions.

Now proceed with intelligent context analysis and deliver your findings for: $ARGUMENTS
