# Agent Instructions

> This file is mirrored across `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md` so the same instructions load in any AI environment.
>
> This file defines **how the agent works**. Project requirements and feature specifications belong in `specs/`, while repeatable workflows belong in `directives/`.

## 1. Operating Model

You operate within a 3-layer architecture that separates decision-making from repeatable execution.

### Layer 1: Specification & Directive — What to do

* `specs/` contains the project's product requirements, architecture decisions, and feature specifications.
* `directives/` contains SOPs for repeatable development workflows.
* Read the relevant specification or directive before implementing work that depends on it.

### Layer 2: Orchestration — Decision making

This is you.

Your responsibility is to:

* Understand the user's request.
* Inspect the existing project before making changes.
* Read relevant specifications and directives.
* Decide which tools, skills, and existing code should be used.
* Break complex work into appropriate steps.
* Handle errors and verify results.
* Ask for clarification when requirements conflict or a significant architectural decision is unclear.

### Layer 3: Execution — Doing the work

Use the project's existing code, tools, scripts, and development environment to execute the planned work.

Prefer deterministic, testable implementations over unnecessary AI-generated complexity.

---

# 2. Project Documentation Hierarchy

Use the following structure as the primary source of project context:

```text
specs/
    ↓
What the application is and what it should do

directives/
    ↓
How specific development tasks should be performed

execution/
    ↓
Reusable scripts/tools when required

.tmp/
    ↓
Temporary and regenerable files
```

### Primary project specification

```text
specs/mobile_application_overview.md
```

This is the primary source of truth for the application's:

* Purpose
* Target users
* Features
* User flows
* Functional requirements
* Product constraints

Do not duplicate this information inside `AGENTS.md`.

If the specification and the current implementation differ, identify the difference before making a major change.

---

# 3. Skill Usage

The project contains installed AI development skills.

Use the appropriate skill when its expertise is relevant rather than attempting to reproduce the workflow manually.

Available skills include:

* `addy-osmani-skills` — software engineering and development practices
* `archify` — architecture and system design
* `caveman` — practical implementation and development workflow
* `frontend-design` — frontend implementation and design quality
* `graphify` — diagrams and visual representations
* `impeccable` — UI quality, refinement, and consistency
* `ponytail` — supporting development workflows and project tasks
* `superpowers` — structured software development and problem-solving workflows
* `ui-ux-design-pro-max` — UI/UX design and interface quality

Before implementing a substantial task, determine whether one or more of these skills are relevant.

Skills should **complement** the project's architecture and specifications, not override them.

Do not use a skill merely because it is available.

---

# 4. Operating Principles

### 1. Inspect first

Before changing code:

* Inspect the relevant files.
* Search for existing implementations.
* Read relevant specifications.
* Check existing dependencies and project structure.
* Reuse existing solutions when appropriate.

Do not immediately create new files or rewrite existing code.

### 2. Preserve the architecture

Do not introduce a new framework, dependency, architecture, or service unless it is actually needed.

Do not replace working implementations simply because another approach is preferred.

### 3. Keep changes focused

Modify only what is necessary for the requested task.

Avoid unrelated refactoring unless it is required to safely implement the change.

### 4. Verify your work

After implementing changes:

* Run the appropriate analyzer/checks.
* Run relevant tests.
* Build or run the application when appropriate.
* Verify the affected functionality.

Never claim that something works without verification.

---

# 5. Self-Annealing

When something breaks:

1. Read the error message and stack trace.
2. Identify the root cause.
3. Fix the implementation.
4. Test the fix.
5. Check for regressions.
6. Document the discovered behavior when it represents reusable project knowledge.

If the problem reveals a missing or incorrect workflow, update the relevant directive.

Do not modify `AGENTS.md` for ordinary feature-specific bugs.

---

# 6. Directives

Before performing a task that has an applicable directive:

1. Read the directive.
2. Follow its defined workflow.
3. Use existing execution tools where available.
4. Do not create duplicate scripts or workflows.

Before creating or substantially changing a directive, ask for confirmation unless the user explicitly requested the directive change.

Directives are living SOPs and should improve when recurring problems or better workflows are discovered.

---

# 7. Codebase Organization

The project structure may evolve.

Do not force the repository into a predetermined directory structure.

Prefer clear separation between:

* UI
* Application logic
* Data models
* Services
* External integrations
* Configuration
* Tests
* Assets

For the mobile application, keep assets organized logically when needed, for example:

```text
assets/
    images/
    icons/
    fonts/
```

Only create directories when they are actually required.

---

# 8. Mobile Development

The application is a mobile application.

When implementing features, consider:

* Android and iOS compatibility.
* Different screen sizes.
* Device permissions.
* Device location.
* Network availability.
* Mobile performance.
* Application lifecycle.
* Physical-device behavior.

Do not assume that a feature working in a desktop environment is automatically valid on a mobile device.

---

# 9. Environment & Security

Keep secrets and environment-specific configuration outside source control.

Use:

```text
.env
.env.example
```

when appropriate.

Never commit:

* API secrets
* Private credentials
* Service keys
* Tokens
* Generated sensitive data

Do not expose privileged backend credentials to the mobile client.

---

# 10. Git & Existing Work

Respect the current Git working state.

Before modifying files with existing uncommitted changes:

* Inspect the changes.
* Avoid overwriting unrelated work.
* Preserve user modifications.

Do not use destructive Git commands to solve development problems without explicit approval.

---

# 11. Clarification & Cost

Ask the user when:

* Requirements conflict.
* A major architectural decision is required.
* The requested behavior is ambiguous in a way that affects implementation.
* A destructive action is required.
* A service may incur unexpected costs.
* Paid API tokens or credits are required.

For ordinary implementation decisions, use the existing specifications and project conventions rather than unnecessarily interrupting the user.

---

# 12. Final Principle

Work as an engineering agent inside an existing project, not as a code generator starting from an empty repository.

The preferred workflow is:

```text
Understand
    ↓
Inspect
    ↓
Read relevant specs/directives/skills
    ↓
Plan
    ↓
Implement
    ↓
Test
    ↓
Verify
    ↓
Document reusable learnings
```

Keep the project pragmatic, maintainable, and understandable to the developers working on it.
