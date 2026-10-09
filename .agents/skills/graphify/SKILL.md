---
name: graphify
description: "Parses codebase, AST structures, schemas, and dependencies into a persistent local knowledge graph. Eliminates token waste by mapping code links, database relationships, and component hierarchies without vector stores."
---

# Graphify — AST-Backed Codebase Knowledge Graph

## Purpose & Core Objective
Graphify parses codebases, database schemas, API routes, and component trees into an indexed, deterministic, local Abstract Syntax Tree (AST) knowledge graph. It maintains deep semantic memory of relations across modules without relying on bulky external vector stores or wasting LLM context tokens re-reading entire directories.

---

## Capabilities & Scope

1. **AST & Dependency Traversal**:
   - Extract imports, exports, class declarations, function signatures, type aliases, and state bindings.
   - Maintain directed graphs of calls, extensions, implementations, and dependencies.

2. **Schema & Data Flow Mapping**:
   - Parse database schemas (SQL, Prisma, Supabase, Firestore, Drift, Room, etc.).
   - Track data flow from persistence layers to API endpoints, state stores, and UI widgets/components.

3. **Impact & Ripple Analysis**:
   - Query upstream and downstream dependents before executing non-trivial refactors.
   - Identify dead code, circular dependencies, and isolated modules.

4. **Zero-Token Waste Ingestion**:
   - Provide pinpoint file and symbol targets so agents load only relevant subgraphs instead of entire repositories.

---

## Operational Protocol

### Step 1: Structural Extraction
When exploring a project or planning a feature:
- Identify key entry points (`index.ts`, `main.dart`, `App.tsx`, `schema.prisma`, etc.).
- Trace outgoing imports to build a module topology:
  ```text
  [Route / Screen] --> [ViewModel / State Store] --> [Repository / Service] --> [Database / API Client]
  ```

### Step 2: Query Before Edit
Before modifying any shared interface or model:
- Run a targeted reference check for all consumers of the modified symbol.
- Assess whether changes break existing contracts.

### Step 3: Minimal Surgical Retrieval
- Never dump full project trees into context.
- Summarize relationships using graph adjacency lists or compact hierarchical paths:
  - `FeatureA -> ServiceB::fetchUser() -> UserSchema`

---

## Integration with Stack Guardrails
- **Ponytail Integration**: Graphify prevents over-engineering by identifying existing native utilities and helpers already defined in the graph before writing redundant code.
- **Superpowers Integration**: Feeds exact impacted file paths directly into `implementation_plan.md` during Layer 2 planning.

