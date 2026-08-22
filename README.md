<h1 align="center">sharpen</h1>

<p align="center">
  <b>Turn a messy request into a prompt your coding agent gets right the first time.</b><br>
  One skill. Works in Claude Code, Cursor, Codex, or any agent that reads a markdown file.
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#what-it-actually-does">How it works</a> ·
  <a href="plugins/sharpen/skills/sharpen/references/examples.md">More examples</a> ·
  <a href="#contributing">Contributing</a>
</p>

---

## The difference

**You type:**

> hey so the login is broken again, users are complaining. i think its the session
> thing again or maybe the token expiry. can you look into it and fix it properly
> this time, and make sure you dont break anything else. thanks

**`/sharpen` gives you:**

```
Login is failing for users. Reproduce the failure, then trace the auth flow —
session handling and token expiry are suspected but unconfirmed, do not assume
either is the cause.

Identify the root cause from the actual implementation, then make the smallest
correct fix following the existing auth patterns.

Verify: a login attempt that previously failed now succeeds, and existing
authenticated routes and logout still work.
```

The agent stops guessing that it's the session. It goes and looks.

---

## Install

### Claude Code — plugin (recommended)

```
/plugin marketplace add sazzadurrahmaan/sharpen
/plugin install sharpen@sharpen
```

### Claude Code — one-liner

```bash
curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/main/scripts/install.sh | bash
```

### Claude Code — manual

```bash
git clone https://github.com/sazzadurrahmaan/sharpen.git
cp -r sharpen/plugins/sharpen/skills/sharpen ~/.claude/skills/sharpen
```

Restart Claude Code. Then:

```
/sharpen fix the checkout thing its been broken since friday
```

### Cursor

```bash
curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/main/adapters/cursor/rules/sharpen.mdc \
  -o ~/.cursor/rules/sharpen.mdc
```

### Codex, Windsurf, Cline, Aider, ChatGPT, anything else

Copy [`dist/sharpen.md`](dist/sharpen.md) into your agent's instruction file
(`AGENTS.md`, `.windsurfrules`, `.clinerules`, a custom GPT, a system prompt — it is
a plain markdown file with no tool dependencies).

---

## What it actually does

Most prompt "optimizers" pad your request into a 400-word specification. That makes
things worse: the agent now has more of your guesses to obey.

sharpen does the opposite. It runs five steps:

1. **Classify** — bug, feature, refactor, review, research, UI, and so on. The class
   decides which instructions are worth spending tokens on.
2. **Extract** — objective, current state, problem, evidence, constraints,
   references. Keeps every file path, error string, and PR number verbatim.
3. **Demote your guesses** — "I think it's the session" becomes a hypothesis the
   agent must confirm, not a premise it acts on.
4. **Write** — outcome, what to investigate, what must not break, how to verify.
   No headings on a one-line task.
5. **Gate** — the prompt ships only if an agent could answer *what changes, why,
   what must stay the same, and how correctness is proven.*

The governing rule:

> **Do not tell the agent what you assume the solution is. Tell it what outcome is
> required, what evidence to inspect, what constraints matter, and let the existing
> codebase determine the implementation.**

It also knows when *not* to produce a prompt. Hand it five unrelated half-described
tasks and it hands you back one question instead of five bad prompts.

---

## Why prompts fail (and what sharpen does about each)

| Failure | What sharpen does |
| --- | --- |
| You guessed the cause; the agent believed you | Converts the guess to a hypothesis with "confirm before changing" |
| Agent invents a new architecture next to your existing one | Requires reading existing patterns first, reuse over rewrite |
| "Don't break anything" → agent refuses to touch existing code | Rewrites it as "preserve behavior outside this change; check callers" |
| Agent fixes the symptom (`?.`, try/catch, retry) | Names the tempting wrong fix explicitly |
| Scope creep — you asked for one fix, got a refactor | Adds a scope fence, only where creep is actually likely |
| Trivial task buried under six headings | Emits a single sentence when a single sentence is right |
| Screenshot hex values hardcoded into your CSS | Requires design tokens, keeps your palette |

---

## Repo layout

```
plugins/sharpen/skills/sharpen/    ← canonical source, edit here
  SKILL.md                           the method (139 lines)
  references/examples.md             9 before/after pairs
  references/by-task-type.md         per-class checklists
dist/sharpen.md                    ← generated single-file build
adapters/cursor/rules/sharpen.mdc  ← generated Cursor rule
scripts/build.sh                     regenerates both
```

`SKILL.md` stays short on purpose — a skill body costs context every time it loads.
The long material sits in `references/` and is read only when the task needs it.
That is [progressive disclosure](https://code.claude.com/docs/en/skills), and it is
the whole reason this is a skill instead of a 3,000-word CLAUDE.md block.

After editing anything under `plugins/`, run:

```bash
./scripts/build.sh
```

---

## Contributing

The most valuable contribution is **a before/after pair**: a real prompt that went
wrong, and the sharpened version that fixed it. Open a PR against
[`references/examples.md`](plugins/sharpen/skills/sharpen/references/examples.md),
or an issue with just the "before" and what the agent did wrong.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
