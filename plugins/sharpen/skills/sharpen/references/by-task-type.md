# Per-class checklists

Read only the section for the class you picked. Each is the delta on top of the
core procedure, not a replacement for it.

---

## Debugging / bug fix

Shape: **symptom → repro → code path → root cause → fix → verification.**

- Never encode the user's suspected cause as fact. Keep it as a named hypothesis.
- Require the cause to be confirmed against the code before the fix is written.
- Ask for the smallest correct fix, not the smallest edit. Those differ: an
  optional chain that hides an undefined is small but wrong.
- Name the tempting-but-wrong fix when there is an obvious one.
- Verification must include the original failing case *and* the behavior nearest
  to the change.
- If the project has tests, ask for a regression test that fails before the fix.

## Feature implementation

Shape: **outcome → existing related code → extension point → implementation → verification.**

- Describe the outcome, not the files. Let the agent find the integration point.
- Require a look at how similar features are already built before any new file.
- If the user proposed a design, preserve it verbatim but mark it as a suggestion
  subject to existing conventions.
- Add a scope fence — feature work is where scope creep is worst.
- Verification is the user-visible behavior, not "the code compiles".

## Refactoring

- State the behavior that must be identical afterward. This is the whole contract.
- Name the boundary: which modules are in scope, which are explicitly not.
- Require the existing tests to pass unchanged. If the tests must change, that is
  a signal the refactor changed behavior — ask for it to be called out.
- Forbid opportunistic fixes bundled into the refactor.

## Code review

Shape per finding: **issue → evidence → impact → recommended direction.**

- Require reading the actual implementation, not just the diff, where the diff
  touches shared code.
- Rank by severity and separate blocking from optional.
- Forbid style preferences reported as defects unless they violate a documented
  project convention.
- Forbid rewrite suggestions without a concrete stated reason.
- Forbid speculative findings — "this could be a problem if" needs a real path.

## Resolving review feedback

- Convert each comment into: locate → verify the concern is real → fix → check
  regressions → confirm resolved.
- Explicitly permit pushing back: if the code disproves the reviewer, say so
  rather than changing code to match.
- If two pieces of feedback conflict, surface the conflict instead of silently
  picking one.
- Preserve the reviewer's exact technical wording where it carries a requirement.

## UI / design work

- The provided design is the source of truth for layout, spacing, hierarchy.
- The existing token system is the source of truth for values. Forbid hardcoded
  hex, px, and font stacks lifted from a screenshot.
- Require reading the existing component and the design system before new markup.
- List the behavior that must survive: interaction states, responsive behavior,
  accessibility attributes, form or selection logic.
- If a Figma or design-tool reference is available, require inspecting it rather
  than eyeballing a screenshot.
- Forbid fabricating copy, data, or imagery. Placeholder content must look like
  placeholder content.

## Research / R&D

- Separate what is known from what is assumed.
- Anchor the question to this project's actual constraints, not the abstract case.
- Require checking the current state of the repo first — it often decides it.
- Demand a recommendation plus what would change it. A comparison matrix with no
  verdict is a non-answer.
- Require stating uncertainty where the evidence is thin, instead of hedging
  everything uniformly.
- Do not inflate a factual lookup into a research project.

## Testing

- Follow the project's existing framework, structure, naming, and fixtures.
- For a bug fix, the valuable test is the one that fails before the fix.
- Forbid tests that assert implementation details rather than behavior.
- Forbid coverage-padding tests unrelated to the change.

## Performance

- Require a measurement before the change and the same measurement after.
- Require the bottleneck to be located, not guessed.
- State the acceptable behavior trade-off, if any. Usually: none.
- Forbid micro-optimizations that hurt readability without a measured win.

## Security / sensitive data

- Preserve existing authentication, authorization, and validation boundaries.
- Forbid weakening validation or access control to make a feature work; if the
  boundary genuinely blocks the requirement, require it be raised, not bypassed.
- Forbid logging, echoing, or committing secrets, tokens, keys, or personal data.
- Follow the project's existing security patterns rather than inventing new ones.
- Include this section only when the task actually touches a security boundary.

## Git / CI / deployment

- Preserve branch names, PR numbers, issue numbers, commit SHAs, and tags exactly.
  Never invent them.
- Include git operations only if the task actually requires them.
- For config and infrastructure changes, verification means checking the resulting
  state, not that the command exited zero.
- Destructive or irreversible operations get an explicit confirmation step.
