<h1 align="center">sharpen</h1>

<p align="center">
  <b>Turn a messy request into a prompt your coding agent gets right the first time.</b><br>
  One <a href="https://agentskills.io">Agent Skills</a> folder — Codex, Claude Code, Cursor, Gemini CLI, Copilot, and 40+ more.
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

sharpen is an [Agent Skills](https://agentskills.io) skill — an open standard
supported by Codex, Claude Code, Cursor, Gemini CLI, Copilot, Amp, OpenCode, Goose,
Kiro, Roo Code, and [40+ other agents](https://agentskills.io/clients). One folder,
no per-tool ports.

**One command, every agent:**

```bash
curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/main/scripts/install.sh | bash
```

Pin to a release instead of tracking `main`:

```bash
SHARPEN_REF=v1.1.1 curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/v1.1.1/scripts/install.sh | bash
```

Installs to `~/.agents/skills/sharpen` (the standard location) and links
`~/.claude/skills/sharpen` for Claude Code. An existing install that you have
edited is moved to `sharpen.backup.<timestamp>` rather than overwritten.
Restart your agent, then:

| Agent | Invoke |
| --- | --- |
| Codex | `$sharpen <your messy prompt>` |
| Claude Code | `/sharpen <your messy prompt>` |
| Cursor | `/sharpen` in Agent chat |
| Everything else | activates on its own when you ask to fix a prompt |

<details>
<summary><b>What you are actually installing</b> — worth checking before piping curl into bash</summary>

Three markdown files and nothing else:

```
sharpen/
├── SKILL.md
└── references/
    ├── examples.md
    └── by-task-type.md
```

No scripts, no executables, no `allowed-tools` grant, no network calls, no
post-install hooks. The skill is inert text that your agent reads — it cannot run
anything on your machine. `install.sh` only clones this repo and copies that folder;
read it first at [`scripts/install.sh`](scripts/install.sh), or use the manual
install below and skip the script entirely. CI enforces that the skill stays
executable-free.

</details>

### Manual

```bash
git clone https://github.com/sazzadurrahmaan/sharpen.git
mkdir -p ~/.agents/skills
cp -r sharpen/plugins/sharpen/skills/sharpen ~/.agents/skills/sharpen
```

Claude Code reads `~/.claude/skills/` rather than the standard path, so also:

```bash
ln -s ~/.agents/skills/sharpen ~/.claude/skills/sharpen
```

### Per-project

Commit it so your whole team gets it:

```bash
mkdir -p .agents/skills
cp -r /path/to/sharpen/plugins/sharpen/skills/sharpen .agents/skills/sharpen
```

### Claude Code plugin

If you'd rather manage it as a plugin than a loose folder:

```
/plugin marketplace add sazzadurrahmaan/sharpen
/plugin install sharpen@sharpen
```

### Agents without skill support

ChatGPT custom GPTs, raw system prompts, Aider, older Windsurf/Cline: paste
[`dist/sharpen.md`](dist/sharpen.md) into the instruction field. It is the whole
skill flattened into one file with no external references.

For Cursor before 2.4 (rules, not skills), use
[`adapters/cursor/rules/sharpen.mdc`](adapters/cursor/rules/sharpen.mdc). On 2.4+
the skill install above is the better path.

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
That is [progressive disclosure](https://agentskills.io/specification#progressive-disclosure),
and it is the whole reason this is a skill instead of a 3,000-word instructions block.

The frontmatter uses only the six fields in the
[Agent Skills spec](https://agentskills.io/specification) — no vendor extensions —
which is why the same folder loads in every client without a port. CI enforces it.

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
