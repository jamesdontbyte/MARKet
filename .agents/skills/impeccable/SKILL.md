---
name: impeccable
description: "Elite design system and aesthetic enforcer. Overrides generic AI template defaults with distinctive typography, deliberate rhythm, intentional palettes, bespoke component styling, and tactical micro-interactions."
---

# Impeccable — Elite Design System & Aesthetic Enforcer

## Purpose & Core Objective
Impeccable acts as a relentless design enforcer, eradicating generic "AI template" aesthetics (indigo/violet hero gradients, cookie-cutter rounded cards, low-contrast washed-out body text, and thoughtless shadows). It enforces deliberate typography, cohesive and high-contrast color palettes, disciplined visual rhythm, and tactile polish.

---

## The Anti-AI Anti-Patterns (Strictly Prohibited)

1. **No Generic Gradient Soup**:
   - Ban default violet-to-cyan or indigo gradients across dark backgrounds without brand justification.
2. **No Cookie-Cutter Nested Cards**:
   - Avoid wrapping every element in identical floating rounded rectangles with identical drop shadows. Use border dividers, whitespace, contrast blocks, or semantic grouping.
3. **No Washed-Out Low Contrast**:
   - Body copy must maintain AAA/AA WCAG contrast ratios against all surfaces.
4. **No Emoji as Interface Icons**:
   - Always use sharp vector SVGs or established icon sets with intentional optical sizing and stroke weights.

---

## Design Directives

### 1. Aesthetic Anchors
Every application must select an intentional aesthetic anchor prior to styling:
- **Clean Utilitarian / Editorial**: High-contrast, sharp typographic hierarchy, restrained accents, intentional grids.
- **Swiss / International Style**: Strict grid alignment, bold grotesque type, disciplined asymmetry.
- **Tactile / Bespoke Dark**: Deep rich tones, subtle border highlights, purposeful elevation rather than noisy blur.

### 2. Typographic Rhythm & Tokens
- Define an intentional type scale with clear semantic purpose (Display, Heading, Subhead, Body, Caption).
- Ensure body text maintains comfortable leading (1.4–1.6) and letter-spacing tuned to font size.

### 3. Tactile States & Polish
- Every interactive element must define distinct states:
  - Default
  - `:hover` / Pointer-over
  - `:active` / Pressed (scale down, brightness shift, tactile feedback)
  - `:focus-visible` (unambiguous, accessible focus indicator)
  - Disabled (clear reduced opacity, disabled pointer events)
- Tap targets on mobile interfaces must meet minimum 44x44px bounding boxes.

---

## Integration with Stack Guardrails
- **UI/UX Pro Max Integration**: Co-pilots UI/UX Pro Max rules by enforcing the higher aesthetic standard and visual polish during implementation.
- **Ponytail Integration**: Delivers elite aesthetics through clean CSS / native widget styling without requiring heavy bloated component libraries.

