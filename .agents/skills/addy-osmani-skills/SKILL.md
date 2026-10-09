---
name: addy-osmani-skills
description: "Production-grade frontend and lifecycle engineering workflows inspired by Addy Osmani. Enforces rigorous architectural standards, clean component modularity, performance budgets, and strict verification gates from spec to production."
---

# Addy Osmani’s Engineering Skills — Production-Grade Frontend & App Lifecycle

## Purpose & Core Objective
Synthesizes modern frontend and mobile application engineering excellence inspired by Addy Osmani's design patterns, performance budgets, and component architectures. Enforces modularity, deterministic state management, performance budgets, and verified release readiness.

---

## Architectural Pillars

### 1. Component Modularity & Design Patterns
- **Single Responsibility Principle (SRP)**: Each component does one thing well. Decouple presentation from business logic (Container/Presentational pattern or ViewModel/View pattern).
- **Composition over Inheritance**: Compose complex widgets out of focused, reusable primitives.
- **Predictable State Flow**: Unidirectional data flow. Avoid scattered two-way bindings or uncontrolled prop mutation.

### 2. Performance Budgets & Vitals
- **Frame Rate Budget**: 60fps/120fps smooth animations; zero layout thrashing or synchronous expensive operations on the UI main thread.
- **Bundle & Memory Discipline**:
  - Lazy load non-critical routes and heavy dynamic modules.
  - Efficient image/asset formats (WebP, SVG, optimized vectors).
  - Clean up event listeners, stream subscriptions, and timers in lifecycle teardowns (`onDestroy`, `useEffect` cleanup, `dispose()`).

### 3. Lifecycle Gates & Verification
- **Gate 1: Contract & Specification Alignment**: Check API and data models before building UI components.
- **Gate 2: Modularity Check**: Ensure components are independently testable and isolated from global state leaks.
- **Gate 3: Error Boundaries & Fallbacks**: Graceful handling for offline modes, slow network responses, and empty data states.
- **Gate 4: Automated Verification**: Strict linting, static type analysis, and zero-error builds prior to feature sign-off.

---

## Operational Workflow

1. **Plan & Scaffold**:
   - Define component interfaces and prop contracts.
   - Separate pure rendering from async side-effects.

2. **Develop with Guardrails**:
   - Implement state updates using immutable patterns.
   - Use memoization or localized rebuilds for performance hotspots.

3. **Verify Quality**:
   - Check performance metrics, memory hygiene, and accessibility tree integrity.
   - Run linter and compiler checks.

---

## Integration with Stack Guardrails
- **Ponytail Integration**: Balances performance engineering with minimalist code: avoid unnecessary third-party libraries or over-engineered abstractions when clean vanilla patterns suffice.
- **UI/UX Pro Max Integration**: Bridges technical performance (CLS, INP, 60fps) with design system visual excellence.

