---
name: sharpen
description: Rewrite a rough, rambling, or vague request into a concise execution-ready prompt for a coding agent. Use when the user says "sharpen this", "optimize this prompt", "improve my prompt", "rewrite this prompt", "make this prompt better", or pastes a messy task description and asks how to phrase it for an AI agent.
license: MIT
---

# Sharpen

Turn a rough request into a prompt an agent can execute correctly on the first try.

**Golden rule:** do not tell the agent what you assume the solution is. Tell it what
outcome is required, what evidence to inspect, what must not break, and let the
existing codebase determine the implementation.

Priority when these conflict: **correctness > intent preservation > execution
quality > token efficiency**. Never trade correctness for brevity.

## Procedure

### 1. Classify

Pick one: bug fix / debugging / feature / refactor / code review / review-feedback
resolution / research / UI / performance / security / testing / docs / infra / mixed.

The class decides which instructions are worth including. Skip the rest.
Class-specific guidance lives in `references/by-task-type.md` — read that file only
for the class you picked, and only when the task is non-trivial.

### 2. Extract the signal

From the user's text, pull out:

| Slot | Question |
| --- | --- |
| Objective | What outcome do they actually want? |
| Current state | What exists now? |
| Problem | What is wrong, missing, or unclear? |
| Evidence | Errors, logs, paths, screenshots, repro steps they gave |
| Constraints | What must not change or break |
| References | Files, branches, PRs, issues, URLs, designs |

Drop greetings, filler, repetition, frustration, self-explanation, and generic
engineering advice. Keep every concrete token: file paths, symbol names, routes,
error strings, branch names, PR numbers, version numbers, URLs.

### 3. Never invent

Do not add requirements, features, APIs, files, dependencies, acceptance criteria,
architecture, or expected behavior the user did not imply. Unknown stays unknown —
unless the agent can discover it from the repo, in which case say so.

Users are often wrong about root cause, file location, and framework behavior.
Convert their guesses into hypotheses, not facts:

> "The API is broken because the controller doesn't validate the request"

becomes

> Investigate the reported API failure across request validation and the surrounding
> request flow. Confirm the actual root cause before changing anything.

### 4. Write the prompt

Include only the sections the task needs. Simple tasks get no headings at all.

```
## Task
<one or two sentences: outcome required>

## Context
<only what the agent cannot discover from the repo>

## Investigate
<what to read/trace before changing anything>

## Requirements
<concrete, checkable>

## Constraints
<what must not change or break>

## Verify
<how correctness is demonstrated>
```

Default clauses, used only where they earn their place:

- **Existing codebase:** "Follow the existing architecture and conventions; reuse
  existing abstractions rather than adding parallel ones."
- **Scope:** "Keep the change scoped to this behavior. No unrelated refactoring,
  cleanup, or dependency upgrades."
- **Root cause:** "Identify the root cause from the actual implementation, then make
  the smallest correct fix." Never "change X until the error goes away."
- **Don't break things:** means modify existing code where needed but check its
  callers and preserve behavior outside the requested change. It does not mean
  "never touch existing code."

One strong instruction beats five overlapping ones. `Make it clean / reusable /
DRY / organized / best practice` collapses into: "Follow the project's existing
patterns; avoid unnecessary duplication and unnecessary abstraction."

### 5. Gate

The sharpened prompt ships only when an experienced agent could answer all of:

1. What exactly must change?
2. Why?
3. What behavior should result?
4. What existing code must be inspected first?
5. What must stay unchanged?
6. Which claims are uncertain?
7. How is correctness verified?

Any gap: pull it from the user's text if present, or tell the agent to investigate
it. Ask the user **only** when the answer is undiscoverable and would materially
change the implementation — one question, not a questionnaire.

## Output

Emit the sharpened prompt in a fenced code block, nothing before it, and no
explanation of what you changed. Then one line offering to run it.

If a genuine blocking ambiguity exists, ask the single question first and stop.

## Anti-patterns

- Turning a one-line request into a 400-word specification.
- Adding "write tests, add error handling, update the docs" when the user asked for
  none of it.
- Prescribing files and function names the user never mentioned.
- Restating a rule in three sections.
- Padding a trivial task with headings.

## More

- `references/examples.md` — before/after pairs. Read these when unsure of the
  target register; they teach faster than the rules above.
- `references/by-task-type.md` — per-class checklists for debugging, features,
  review feedback, code review, UI, research, testing, security, and git work.
