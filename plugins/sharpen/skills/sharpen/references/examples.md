# Before / after

Nine pairs. The pattern to internalize: **the "after" is not longer, it is
load-bearing.** Every added sentence tells the agent something it could not have
guessed; every removed sentence was noise, a wrong guess, or a restatement.

---

## 1. Vague bug report

**Before**

> hey so the login is broken again, users are complaining. i think its the session
> thing again or maybe the token expiry. can you look into it and fix it properly
> this time, and make sure you dont break anything else. thanks

**After**

```
Login is failing for users. Reproduce the failure, then trace the auth flow —
session handling and token expiry are suspected but unconfirmed, do not assume
either is the cause.

Identify the root cause from the actual implementation, then make the smallest
correct fix following the existing auth patterns.

Verify: a login attempt that previously failed now succeeds, and existing
authenticated routes and logout still work.
```

Why: "I think it's X" became a hypothesis, not a premise. "Don't break anything"
became a concrete regression check. "Properly" was noise.

---

## 2. Feature request with prescribed architecture

**Before**

> I want to add CSV export to the reports page. Create a new `CsvExportService`
> class in `src/services/`, inject it into the reports controller, add a new
> `/api/reports/export` endpoint, and use the `fast-csv` package.

**After**

```
Add CSV export to the reports page.

Before implementing: check how the app already handles file downloads and data
serialization, and whether a CSV or export utility already exists. Extend the
existing path if there is one.

The user proposed a CsvExportService in src/services/, a POST /api/reports/export
endpoint, and the fast-csv package. Treat that as a suggestion — follow it only
where it matches existing conventions, and say so if you deviate.

Keep the change scoped to this feature. Verify the exported file opens correctly
and contains the same rows the reports page displays.
```

Why: a user-supplied design is real signal, so it is preserved — but demoted from
mandate to suggestion, because the repo may already solve this. Never silently
delete the user's proposal.

---

## 3. Already-precise request

**Before**

> In `src/utils/date.ts`, `formatRelative` returns "in 0 days" for today. It should
> return "today".

**After**

```
In src/utils/date.ts, formatRelative returns "in 0 days" for today's date; it
should return "today". Fix and check the surrounding boundary cases (yesterday,
tomorrow) behave sensibly. Add or update a test if the file has coverage.
```

Why: **almost nothing changed.** A precise request needs no ceremony. Wrapping this
in six headings would be malpractice.

---

## 4. Rambling refactor request

**Before**

> our codebase is kind of a mess honestly. the user profile stuff is spread across
> like 5 files and theres duplicate validation logic everywhere, plus some of it is
> in the component and some in the api layer. i feel like we should clean this up
> and maybe introduce a proper domain layer? what do you think. anyway the immediate
> thing is that changing a users email doesnt revalidate their phone number format
> and it should.

**After**

```
Bug: changing a user's email does not re-run phone number format validation, and
it should.

Map where user profile validation currently lives — it appears duplicated across
the component layer and the API layer. Fix the bug in whichever layer is the
correct single source of truth for this rule, and make the other paths use it
rather than duplicating.

Keep the change scoped to profile validation. Do not introduce a new domain layer
or restructure unrelated modules.

Verify: updating an email revalidates the phone number, existing profile updates
still work, and validation behavior is unchanged elsewhere.
```

Why: the buried actual request ("anyway the immediate thing is...") is the task.
The architectural musing becomes a scope fence, not a mandate. Note the last line
of the "before" is the first line of the "after".

---

## 5. Pasted stack trace, no question

**Before**

> ```
> TypeError: Cannot read properties of undefined (reading 'map')
>     at ProductGrid (ProductGrid.tsx:47:23)
>     at renderWithHooks (react-dom.development.js:16305:18)
> ```

**After**

```
Fix this error:

TypeError: Cannot read properties of undefined (reading 'map')
    at ProductGrid (ProductGrid.tsx:47:23)

Trace what feeds the mapped value at ProductGrid.tsx:47 and determine why it is
undefined at render time — a missing default, a loading state rendered before data
arrives, or a failed fetch. Fix the actual cause rather than adding an optional
chain at the call site, unless the surrounding code establishes that as the
project's pattern.

Verify the component renders in both the loading and loaded states.
```

Why: names the specific wrong fix the agent would otherwise reach for. The
`?.` band-aid is the single most common failure mode on this class of bug.

---

## 6. Review feedback

**Before**

> senior dev said: "this N+1 query in the dashboard is going to melt prod, and the
> error handling swallows exceptions". need to fix before merge

**After**

```
Resolve two review blockers on the dashboard code before merge:

1. An N+1 query pattern. Locate it, confirm it is real by inspecting the query
   path, then fix it using the project's existing eager-loading or batching
   approach.
2. Exception swallowing in error handling. Locate where exceptions are caught
   and discarded, and align with the project's existing error-handling and
   logging convention.

For each: confirm the concern is valid against the actual code before changing it.
If either is not actually present as described, say so rather than changing code
to match the review.

Verify the dashboard returns identical data with fewer queries, and that errors now
surface through the project's normal channel.
```

Why: review feedback is not automatically correct. "Confirm before changing" is
the load-bearing clause.

---

## 7. Overloaded multi-task dump

**Before**

> can you fix the checkout bug, also update the readme, also i noticed the deps are
> old, also the mobile nav is broken on ios safari, and we should probably add tests

**After**

```
Five separate tasks were requested. Doing them in one pass produces an unreviewable
diff, so they are ordered by risk — confirm the order or pick one to start:

1. Checkout bug — needs a description of the failure and repro steps before it can
   be worked on.
2. Mobile nav broken on iOS Safari — needs the specific breakage described.
3. Test coverage — needs a target area.
4. Dependency updates — separate change, separate review.
5. README update — needs to know what is out of date.

Which one first, and what are the details for it?
```

Why: sometimes the right output is not a prompt. Five unrelated tasks, three of
them underspecified, cannot be sharpened into one good prompt — pretending
otherwise produces confident garbage.

---

## 8. UI from a screenshot

**Before**

> make the pricing cards look like this [screenshot] but keep our colors

**After**

```
Update the pricing cards to match the attached screenshot's layout, spacing, and
hierarchy.

Before writing CSS, read the existing pricing card component and the project's
design tokens. Use existing tokens for color, spacing, radius, typography, and
shadow — do not hardcode values from the screenshot, and keep the current color
palette.

Preserve existing behavior: interaction states, responsive breakpoints, and any
plan-selection logic.

Verify at mobile and desktop widths, and in every state the component already
supports.
```

Why: "keep our colors" generalizes to "use the token system". Screenshots leak
hardcoded hex values into codebases; this is the clause that stops it.

---

## 9. Research question

**Before**

> should we use redis or postgres for our job queue? do a deep dive and compare
> everything, look at benchmarks, scaling, cost, ecosystem, ops burden, everything

**After**

```
Recommend Redis or Postgres as the job queue backend for this project.

First check what the project already runs — if one of the two is already deployed
and operated, that changes the answer, and the comparison should be framed against
the real alternative rather than in the abstract.

Then evaluate against this project's actual requirements: expected job volume,
durability needs, retry/scheduling semantics in use, and existing ops tooling.

Give one recommendation with the two or three reasons that decide it, and state
what would change the answer. Skip dimensions that do not affect this decision.
```

Why: "compare everything" is a research trap. The sharpened version forces the
comparison to be about *this* project and demands a decision, not a matrix.
