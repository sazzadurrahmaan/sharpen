# Contributing

## The one thing that helps most

A **before/after pair** from real work: a prompt that made an agent do the wrong
thing, and the sharpened version that fixed it.

Open an issue with:

- **Before** — the prompt you actually typed, verbatim, warts included
- **What went wrong** — what the agent did instead of what you wanted
- **After** — the version that worked, if you found one

You do not need the "after". The "before" plus the failure is the valuable half.

## Editing the skill

`plugins/sharpen/skills/sharpen/` is the only place to edit. `dist/` and
`adapters/` are generated.

```bash
./scripts/build.sh   # regenerate, then commit the result
```

CI fails if the generated files are out of sync with the source.

## Standards for changes to SKILL.md

`SKILL.md` loads into context on every invocation, so it stays under ~150 lines.
A pull request that adds to it should either:

- **remove** at least as many lines as it adds, or
- put the new material in `references/` instead.

Before adding a rule, check it is not already covered. The predecessor of this
skill had seven sections that all said "investigate before changing, reuse
existing code, don't over-abstract". One is enough.

New rules need a failure case. If you cannot name a prompt that goes wrong without
the rule, the rule is not earning its tokens.

## Examples

Keep the existing shape: **Before → After → Why.** The "Why" line names the
specific failure the rewrite prevents, in one or two sentences. Examples that only
demonstrate "it got longer and more formal" will be declined — that is the failure
mode this project exists to avoid.
