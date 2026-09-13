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

**Attachments survive sharpening — always.** Anything the user attached or pointed
at alongside the raw prompt is part of the prompt: images/screenshots, file paths,
links, PR/issue numbers, log excerpts. The sharpened prompt must carry every one of
them forward explicitly:

- Images/screenshots: reference each one positionally in the prompt text — "the
  attached screenshot" / "attached image #2 (the error state)" — and say what it
  shows if the user said so. Never silently omit an attached image; the executing
  agent will receive it alongside the sharpened text.
- File paths, URLs, links: copy verbatim into the `References` / `Context` section,
  character for character. Never paraphrase a path or shorten a URL.
- If the raw prompt's meaning depends on an attachment ("fix this: <screenshot>"),
  the sharpened prompt must state that dependency: "See the attached screenshot for
  the broken state."

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

Include only the sections the task needs. Simple tasks get no other headings;
`## Standards` and `## Skills` are always present, even then.

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

## Standards
<the fixed engineering bar — always present, see below>

## Skills
<skills to invoke, in order, before any other action>
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

One strong instruction beats five overlapping ones. Vague quality words in the
user's text (`clean / reusable / DRY / organized / best practice`) are already
covered by the Standards block — do not restate them elsewhere in the prompt.

**Standards block — always emitted, verbatim, as the `## Standards` section.**
This is the engineering bar every sharpened prompt carries, whatever the task:

```
## Standards
- Keep the result organized and optimized; no dead code, no leftovers.
- Do not damage any existing feature — check callers and preserve behavior outside the change.
- Follow industry-standard best practices for this stack.
- Reuse existing code, files, and abstractions; never duplicate logic.
- Follow the codebase's existing patterns and conventions.
- Comments: one line max, only on genuinely important parts, short words.
- No unnecessary change — nothing outside what the task needs.
```

Do not paraphrase, reorder, or trim it. Task-specific constraints go in
`## Constraints`; the Standards block stays generic and fixed.

### 5. Attach skills

Always end the prompt with a `## Skills` section: the skills the executing agent
must invoke, in order, before reading or changing anything.

**Select dynamically, every time.** Read the skill list available in the current
session (the "available skills" listing, plugin skills, project `.claude/skills/`)
and match each skill's description against what the task actually touches. Never
use a fixed mapping, never invent a name, never list a skill that is not offered
in this session.

Walk it in this order:

1. **Process skill** — one, chosen by the class from step 1. Debugging or a bug
   fix wants a root-cause skill (e.g. `superpowers:systematic-debugging`); a
   feature or refactor wants design-then-test skills (e.g.
   `superpowers:brainstorming` for non-trivial scope, then
   `superpowers:test-driven-development`); a review wants the review skill; PR
   feedback wants the respond-to-review skill. Skip brainstorming for a change
   that is obviously small.
2. **Domain skills** — scan the descriptions for the nouns in the task: the
   stack (Laravel, Vue, Inertia, Tailwind, Pest…), the surface (UI/UX, API,
   billing, auth, queues, browser…), the artifact (screenshot, PR, release…).
   A UI or visual task pulls in the design and styling skills on offer (e.g.
   `frontend-design`, `ui-ux-pro-max:ui-styling`, `tailwindcss-development`,
   `inertia-vue-development`) plus a browser skill for visual verification. A
   backend task pulls in the framework and testing skills. A billing, auth, or
   other project-specific area pulls in that project's own skill first —
   project skills outrank generic ones.
3. **Verification skill** — end with the session's completion-check skill (e.g.
   `superpowers:verification-before-completion`).

Format each entry as `- skill-name — one-line reason tied to this task`. Three
to six entries is normal; do not pad, and drop any skill whose reason you cannot
state in one line. When the user later says "run", invoke every listed skill in
that order before starting the work.

### 6. Gate

The sharpened prompt ships only when an experienced agent could answer all of:

1. What exactly must change?
2. Why?
3. What behavior should result?
4. What existing code must be inspected first?
5. What must stay unchanged?
6. Which claims are uncertain?
7. How is correctness verified?
8. Which skills must be loaded first?
9. Is the Standards block present and unedited?

Any gap: pull it from the user's text if present, or tell the agent to investigate
it. Ask the user **only** when the answer is undiscoverable and would materially
change the implementation — one question, not a questionnaire.

## Output

Emit the sharpened prompt in a fenced code block, nothing before it, and no
explanation of what you changed. Then one line offering to run it.

Before emitting, check: every attachment, file path, and link from the raw prompt
appears in the sharpened prompt. If even one is missing, the output is wrong.

When the user answers "run" (or "go", "do it"): invoke each skill in the
`## Skills` section in order via the Skill tool, then execute the prompt. Do not
ask which skills to use — the list is the answer.

If a genuine blocking ambiguity exists, ask the single question first and stop.

## Anti-patterns

- Dropping an attached image, file path, or link from the sharpened prompt.
- Turning a one-line request into a 400-word specification.
- Adding "write tests, add error handling, update the docs" when the user asked for
  none of it.
- Prescribing files and function names the user never mentioned.
- Restating a rule in three sections (the Standards block already covers quality;
  do not echo it in Requirements or Constraints).
- Padding a trivial task with headings.

## More

- `references/examples.md` — before/after pairs. Read these when unsure of the
  target register; they teach faster than the rules above.
- `references/by-task-type.md` — per-class checklists for debugging, features,
  review feedback, code review, UI, research, testing, security, and git work.
