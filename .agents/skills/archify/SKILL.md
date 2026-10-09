---
name: archify
description: "Automated visual architecture and system flow mapping. Generates standalone, interactive HTML and Mermaid diagrams for system architecture, data pipelines, backend models, and component hierarchies."
---

# Archify — Automated Visual Architecture Mapping

## Purpose & Core Objective
Archify transforms system designs, backend relationships, state transitions, and component trees into clear visual blueprints. It generates interactive HTML diagrams and structured Mermaid charts to communicate complex architectures with zero ambiguity.

---

## Supported Diagram Types

1. **System & Service Topology**:
   - Client applications, API gateways, microservices, databases, caching layers, and external third-party integrations.

2. **Data & State Flow**:
   - Unidirectional data flows (e.g., Redux, Bloc, Riverpod, Zustand, or TanStack Query).
   - Event sourcing, WebSocket channels, and async message queues.

3. **Database & Schema Entity-Relationship (ERD)**:
   - Tables, foreign keys, cardinality (1:1, 1:N, N:M), indexes, and schema partitions.

4. **Component Hierarchy & Screen Navigation**:
   - Mobile navigation stacks, tab bars, modal sheets, and nested component subtrees.

---

## Output Protocols

### Mode A: Mermaid Syntax (Inline & Documentation)
Use standard fenced Mermaid blocks in `specs/`, `implementation_plan.md`, or pull request descriptions:
- Flowcharts: `flowchart TD` / `flowchart LR`
- Sequence: `sequenceDiagram`
- State: `stateDiagram-v2`
- Entity Relationship: `erDiagram`

### Mode B: Interactive HTML Blueprints (Artifacts)
When a system diagram requires zoom, pan, collapsible nodes, or interactive exploration:
- Produce a standalone, zero-dependency HTML file using inline SVG, HTML5 Canvas, or embedded SVG diagrams.
- Include CSS transitions and responsive canvas controls for interactive inspection.

---

## Operational Triggers
- When introducing a new feature spanning multiple layers (Layer 1 Intent & Specs).
- When altering database relationships or major state management workflows.
- When drafting `implementation_plan.md` for multi-component mobile/web architectures.

