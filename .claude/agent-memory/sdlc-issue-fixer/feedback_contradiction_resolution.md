---
name: feedback-contradiction-resolution
description: When a skill states a guarantee and another step violates it, the owner wants the violating step narrowed, not the guarantee dropped.
metadata:
  type: feedback
---

# Resolving stated-guarantee contradictions

When a review finds that a document states a guarantee and some other
step contradicts it, narrow the contradicting step so it honors the
guarantee. Do not delete or weaken the guarantee to make the
contradiction go away.

**Why:** the guarantee carries the design intent. The step that breaks
it is the accident, so the step is what gives way.

**How to apply:** on any finding of the form "X promises P, Y breaks
P", default to editing Y. Ask before touching the promise itself.
