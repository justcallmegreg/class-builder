# Class Builder Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `class-builder` Claude Code skill that turns a repository into staged class materials (objectives, 10-slide presentation with full speaker scripts, lab/demo, workbook quiz) as structured Markdown.

**Architecture:** The skill is a `SKILL.md` workflow plus five `references/` templates. `SKILL.md` drives a 7-step staged process with author checkpoints; each artifact type has a dedicated reference template encoding its pedagogical rules. A `tests/validate.sh` script structurally validates every file (frontmatter, required section markers) and acts as the failing-test harness. A fixture repo under `tests/fixtures/` enables an end-to-end smoke test.

**Tech Stack:** Markdown (skill + templates), Bash (validation harness), Claude Code skill conventions (`superpowers:writing-skills`).

---

## File Structure

Skill files live at the repo root so the repo itself is the installable skill directory:

- `SKILL.md` — frontmatter + the 7-step staged workflow. One responsibility: orchestrate the run and point to templates.
- `references/pedagogy.md` — the "why": Bloom verbs, constructive alignment, the rules behind every artifact.
- `references/presentation-template.md` — slide block format + the full-commentary speaker-script rule + 10/20/30 + Problem→Solution→Reasoning arc.
- `references/lab-template.md` — lab/demo structure.
- `references/workbook-template.md` — 10 MCQ + 3 free-text format, rubrics, timing.
- `references/glossary-rules.md` — the `*` abbreviation convention.
- `tests/validate.sh` — structural validator (the failing-test harness).
- `tests/fixtures/sample-repo/` — tiny fixture repo (README.md, NOTES.md, notes/) for the smoke test.
- `README.md` — project overview + install instructions.

Spec reference: `docs/superpowers/specs/2026-06-10-class-builder-design.md`.

---

## Task 1: Validation harness + README scaffold

**Files:**
- Create: `tests/validate.sh`
- Create: `README.md`

This task writes the validator that asserts every skill file exists with its required markers. Running it now fails on everything — that is the suite-wide "see it fail". Each later task turns its slice green.

- [ ] **Step 1: Write the validation harness (the failing test)**

Create `tests/validate.sh`:

```bash
#!/usr/bin/env bash
# Structural validator for the class-builder skill.
# Each check greps a required marker in a target file. Prints PASS/FAIL per
# check and exits non-zero if any check fails.
set -u
cd "$(dirname "$0")/.." || exit 2

fail=0
check() { # check <description> <file> <grep-pattern>
  if [ -f "$2" ] && grep -qiE "$3" "$2"; then
    echo "PASS  $1"
  else
    echo "FAIL  $1"
    fail=1
  fi
}

# SKILL.md
check "SKILL frontmatter name"        SKILL.md "^name: class-builder"
check "SKILL frontmatter description" SKILL.md "^description: .+"
check "SKILL step 0 discover"         SKILL.md "Step 0"
check "SKILL step 6 glossary"         SKILL.md "Step 6"
check "SKILL approval checkpoint"     SKILL.md "\[APPROVE\]"

# pedagogy.md
check "pedagogy constructive alignment" references/pedagogy.md "constructive alignment"
check "pedagogy bloom"                   references/pedagogy.md "bloom"
check "pedagogy 10/20/30"                references/pedagogy.md "10/20/30"

# presentation-template.md
check "presentation speaker script"   references/presentation-template.md "speaker script"
check "presentation memorizable"      references/presentation-template.md "memoriz"
check "presentation word budget"      references/presentation-template.md "250"
check "presentation arc"              references/presentation-template.md "Problem"
check "presentation mermaid"          references/presentation-template.md "mermaid"

# lab-template.md
check "lab prerequisites" references/lab-template.md "prerequisite"
check "lab validation"    references/lab-template.md "validation|how to know"

# workbook-template.md
check "workbook 10 mcq"     references/workbook-template.md "multiple-choice"
check "workbook 3 freetext" references/workbook-template.md "free-text"
check "workbook rubric"     references/workbook-template.md "rubric"
check "workbook LO tag"     references/workbook-template.md "LO"

# glossary-rules.md
check "glossary asterisk rule" references/glossary-rules.md "trailing .\*. |every use|every occurrence"
check "glossary file"          references/glossary-rules.md "glossary.md"

echo "----"
if [ "$fail" -eq 0 ]; then echo "ALL CHECKS PASS"; else echo "SOME CHECKS FAILED"; fi
exit "$fail"
```

- [ ] **Step 2: Make it executable and run it to verify it fails**

```bash
chmod +x tests/validate.sh && bash tests/validate.sh
```

Expected: many `FAIL` lines and final `SOME CHECKS FAILED` (exit 1) — only files that don't exist yet.

- [ ] **Step 3: Write the README scaffold**

Create `README.md`:

```markdown
# class-builder

A Claude Code skill that turns a repository into class teaching materials:
learning objectives, a short presentation (with full speaker scripts), a
lab/demo, and a workbook quiz — all as structured Markdown.

Grounded in pedagogy: constructive alignment, the 10/20/30 rule, Bloom's
taxonomy, and a Problem → Solution → Reasoning narrative arc.

## Install

Symlink this repo into your personal skills directory:

```bash
ln -s "$PWD" ~/.claude/skills/class-builder
```

Then invoke it in Claude Code by pointing it at a repository you want to teach.

## Validate

```bash
bash tests/validate.sh
```

## Design

See `docs/superpowers/specs/2026-06-10-class-builder-design.md`.
```

- [ ] **Step 4: Commit**

```bash
git add tests/validate.sh README.md
git commit -m "test: add structural validation harness and README scaffold"
```

---

## Task 2: SKILL.md — the staged workflow

**Files:**
- Create: `SKILL.md`

- [ ] **Step 1: Confirm the SKILL checks fail**

```bash
bash tests/validate.sh | grep SKILL
```

Expected: all `FAIL SKILL ...` lines (file doesn't exist yet).

- [ ] **Step 2: Write SKILL.md**

Create `SKILL.md`:

````markdown
---
name: class-builder
description: Use when turning a repository into class or lab teaching materials — generates learning objectives, a 10-slide presentation with full memorizable speaker scripts, a lab/demo, and a workbook quiz as structured Markdown, grounded in pedagogy (constructive alignment, 10/20/30, Bloom, problem-solution-reasoning).
---

# Class Builder

Turn a repository into a coherent class: objectives, presentation, lab, and
workbook. Output is structured **Markdown content** the author finishes manually
(e.g. building real slides) — not finished decks.

Run as a **staged workflow with author checkpoints**. Do not skip ahead: the
objectives must be approved before they propagate into three artifacts.

Read `references/pedagogy.md` before generating, then the artifact-specific
template at each step.

## Step 0 — Discover

Scan the repo to understand its content. Read in priority order, stopping early
once you have enough to propose topics:

1. `NOTES.md` (the author's AI-friendly index of `notes/`) — read this FIRST
2. `notes/`
3. `docs/`
4. `README.md`
5. code structure

## Step 1 — Gather inputs

Ask the author (propose candidates/defaults where possible):

- **Topic / scope** — propose candidate topics derived from `NOTES.md`/`docs/`/`README.md`; author picks or refines.
- **Audience level** — beginner / intermediate / advanced.
- **Lab style** — hands-on (audience executes) vs. presenter demo.
- **Prior knowledge** — what the audience already knows.

## Step 2 — Learning objectives → `classes/<topic-slug>/00-objectives.md`  [APPROVE]

Produce 3–5 objectives. Each uses a Bloom action verb suited to the audience
level and gets a stable ID (`LO1`, `LO2`, …). Every later artifact tags the LO
it serves. **Get the author's approval before continuing.**

## Step 3 — Presentation → `classes/<topic-slug>/01-presentation.md`  [REVIEW]

Follow `references/presentation-template.md`. 10 slides max, Problem → Solution →
Reasoning arc, Mermaid diagrams, plain clean English, `*`-marked abbreviations,
and a **full memorizable speaker script per slide**. Pause for author review.

## Step 4 — Lab → `classes/<topic-slug>/02-lab.md`  [REVIEW]

Follow `references/lab-template.md`. Lab style (from Step 1) changes only
phrasing. Tag each step with its LO. Pause for author review.

## Step 5 — Workbook → `classes/<topic-slug>/03-workbook.md`  [REVIEW]

Follow `references/workbook-template.md`. 10 conceptual multiple-choice + 3
tutor-reviewed free-text questions, each tagged with its LO. Pause for review.

## Step 6 — Glossary → `classes/<topic-slug>/glossary.md`

Collect every `*`-marked short form into the canonical resolution table.
Follow `references/glossary-rules.md`.

## Output layout

```
classes/<topic-slug>/
  00-objectives.md
  01-presentation.md
  02-lab.md
  03-workbook.md
  glossary.md
```
````

- [ ] **Step 3: Run validator to verify SKILL checks pass**

```bash
bash tests/validate.sh | grep SKILL
```

Expected: all five `PASS SKILL ...` lines.

- [ ] **Step 4: Commit**

```bash
git add SKILL.md
git commit -m "feat: add SKILL.md staged class workflow"
```

---

## Task 3: references/pedagogy.md

**Files:**
- Create: `references/pedagogy.md`

- [ ] **Step 1: Confirm pedagogy checks fail**

```bash
bash tests/validate.sh | grep pedagogy
```

Expected: `FAIL pedagogy ...` lines.

- [ ] **Step 2: Write references/pedagogy.md**

Create `references/pedagogy.md`:

```markdown
# Pedagogy — the rules behind every artifact

Read this before generating. These principles are why each rule exists; apply
them when judgment is needed.

## Constructive alignment (Biggs)
Objectives come first. Every slide, lab step, and quiz question references the
objective (`LOn`) it serves. An objective with no quiz question is a coverage
gap — flag it. This is what keeps three artifacts coherent.

## Problem → Solution → Reasoning
The presentation's narrative spine. Lead with the pain, then the fix, then the
justification (maps to Sinek's Why/What/How and problem-based learning).

## 10/20/30 rule (Kawasaki)
10 slides max, 20 minutes max, 30pt font. Ruthlessly cut.

## Multimedia + dual coding (Mayer)
Minimize text, prefer visuals. Diagrams default to Mermaid (markdown-native).

## Cognitive load
One idea per slide. Plain, clean English. Short sentences.

## Bloom's taxonomy
Workbook questions target Understand / Apply / Analyze (conceptual), never
Remember (recall). Objective verbs scale with audience level:
- beginner: explain, describe, identify, classify
- intermediate: apply, compare, predict, differentiate
- advanced: analyze, evaluate, design, justify

## Experiential learning (Kolb)
The lab/demo is the concrete "do" phase. Who executes it is irrelevant to its
role — only the phrasing changes (copy-paste vs. narrated).

## Retrieval practice
The workbook is the retrieval step that cements learning.
```

- [ ] **Step 3: Run validator to verify pedagogy checks pass**

```bash
bash tests/validate.sh | grep pedagogy
```

Expected: three `PASS pedagogy ...` lines.

- [ ] **Step 4: Commit**

```bash
git add references/pedagogy.md
git commit -m "feat: add pedagogy reference"
```

---

## Task 4: references/presentation-template.md

**Files:**
- Create: `references/presentation-template.md`

- [ ] **Step 1: Confirm presentation checks fail**

```bash
bash tests/validate.sh | grep presentation
```

Expected: `FAIL presentation ...` lines.

- [ ] **Step 2: Write references/presentation-template.md**

Create `references/presentation-template.md`:

````markdown
# Presentation template

Output file: `classes/<topic-slug>/01-presentation.md`.

## Rules
- **10 slides max.** Bucket into the Problem → Solution → Reasoning arc
  (roughly 3 / 4 / 3 slides).
- Start the file with a reminder header: `> 20 min · 30pt font · 10 slides`.
- One idea per slide. Plain, clean English.
- Mark every abbreviation with a trailing `*` (see glossary-rules.md).
- Diagrams default to Mermaid; if a visual isn't diagrammable, describe it.
- Tag each slide with the objective it serves, e.g. `[LO1]`.

## Speaker script — full memorizable commentary
The speaker script is NOT bullet reminders. It is a complete, spoken-word
narrative the presenter can read aloud or memorize like a mini-speech. Each one:
- is continuous prose in the same plain, clean English as the slide,
- carries that slide's Problem/Solution/Reasoning beat,
- **transitions into the next slide** so the talk feels continuous,
- is ~250–300 words (~2 minutes), keeping the whole deck within 20 minutes.

## Slide block format
```
## Slide N — <title>   [LOx]
**Purpose:** <one line: what this slide accomplishes>
**Content:**
- <bullet — one idea, plain English>
**Visual:** <```mermaid``` diagram, or a described visual>
**Speaker script:** <~250–300 words of memorizable spoken narrative that lands
this slide's point and hands off to the next slide>
```
````

- [ ] **Step 3: Run validator to verify presentation checks pass**

```bash
bash tests/validate.sh | grep presentation
```

Expected: five `PASS presentation ...` lines.

- [ ] **Step 4: Commit**

```bash
git add references/presentation-template.md
git commit -m "feat: add presentation template with full-commentary speaker rule"
```

---

## Task 5: references/lab-template.md

**Files:**
- Create: `references/lab-template.md`

- [ ] **Step 1: Confirm lab checks fail**

```bash
bash tests/validate.sh | grep "lab "
```

Expected: `FAIL lab ...` lines.

- [ ] **Step 2: Write references/lab-template.md**

Create `references/lab-template.md`:

```markdown
# Lab template

Output file: `classes/<topic-slug>/02-lab.md`.

Lab style (hands-on vs. presenter demo) is set in Step 1 and changes only
phrasing — copy-paste-ready commands for hands-on, narrated walkthrough for a
demo. Structure is the same either way.

## Structure
```
# Lab — <title>

## Prerequisites & setup
- <tools, accounts, environment>

## Steps
### Step 1 — <action>   [LOx]
<instruction; copy-paste command OR narrated walkthrough per lab style>

## Expected outcome / how to know it worked (validation)
- <observable result that proves the step succeeded>

## Stretch / optional
- <optional extension for fast finishers>
```

## Rules
- Tag each step with the objective it reinforces (`[LOx]`).
- Every lab must include a **validation** section so success is observable.
- Mark abbreviations with `*`.
```

- [ ] **Step 3: Run validator to verify lab checks pass**

```bash
bash tests/validate.sh | grep "lab "
```

Expected: two `PASS lab ...` lines.

- [ ] **Step 4: Commit**

```bash
git add references/lab-template.md
git commit -m "feat: add lab template"
```

---

## Task 6: references/workbook-template.md

**Files:**
- Create: `references/workbook-template.md`

- [ ] **Step 1: Confirm workbook checks fail**

```bash
bash tests/validate.sh | grep workbook
```

Expected: `FAIL workbook ...` lines.

- [ ] **Step 2: Write references/workbook-template.md**

Create `references/workbook-template.md`:

```markdown
# Workbook template

Output file: `classes/<topic-slug>/03-workbook.md`.

## Composition
- **10 multiple-choice questions** — conceptual (Bloom Understand / Apply /
  Analyze, never recall). 1 correct answer + plausible distractors.
- **3 free-text questions** — tutor-reviewed; each carries a grading rubric.
- Tag every question with its objective (`[LOx]`).
- Show the timing budget at the top:
  `10 × (1–2 min) + 3 × (up to 5 min) ≈ 25–35 min`.

## Answer key
Put the multiple-choice answer key + a one-line rationale per question in a
separate appendix section at the END, so the student copy above stays clean.

## Format
```
# Workbook — <title>
> Time: 10 × (1–2 min) + 3 × (up to 5 min) ≈ 25–35 min

## Part A — Multiple choice
### Q1   [LOx]
<conceptual question>
- A) <option>
- B) <option>
- C) <option>
- D) <option>

## Part B — Free text (tutor-reviewed)
### Q11   [LOx]
<open conceptual question>
**Rubric:** <what a good answer contains>

---
## Appendix — Answer key (instructor copy)
- Q1: B — <one-line rationale>
```
```

- [ ] **Step 3: Run validator to verify workbook checks pass**

```bash
bash tests/validate.sh | grep workbook
```

Expected: four `PASS workbook ...` lines.

- [ ] **Step 4: Commit**

```bash
git add references/workbook-template.md
git commit -m "feat: add workbook template"
```

---

## Task 7: references/glossary-rules.md

**Files:**
- Create: `references/glossary-rules.md`

- [ ] **Step 1: Confirm glossary checks fail**

```bash
bash tests/validate.sh | grep glossary
```

Expected: `FAIL glossary ...` lines.

- [ ] **Step 2: Write references/glossary-rules.md**

Create `references/glossary-rules.md`:

```markdown
# Glossary rules — the `*` abbreviation convention

Output file: `classes/<topic-slug>/glossary.md`.

## Marking
- Write every short form with a trailing `*` at **every occurrence** (not just
  first use) — slides may be shown out of order, so each use is self-flagging.
- Examples: `AWS*`, `IAM*`, `CI*`.

## Resolution
- `glossary.md` is the canonical resolution table, accumulated across all
  artifacts:
  ```
  | Term | Expansion |
  |------|-----------|
  | AWS* | Amazon Web Services |
  | IAM* | Identity and Access Management |
  ```
- Build it last (Step 6) by collecting every `*`-marked term from the
  objectives, presentation, lab, and workbook.
```

- [ ] **Step 3: Run validator to verify glossary checks pass**

```bash
bash tests/validate.sh | grep glossary
```

Expected: two `PASS glossary ...` lines.

- [ ] **Step 4: Commit**

```bash
git add references/glossary-rules.md
git commit -m "feat: add glossary rules"
```

---

## Task 8: Fixture repo + full-suite smoke test

**Files:**
- Create: `tests/fixtures/sample-repo/README.md`
- Create: `tests/fixtures/sample-repo/NOTES.md`
- Create: `tests/fixtures/sample-repo/notes/rate-limiting.md`

This task confirms the whole suite is green and provides a tiny repo to manually
exercise the skill end-to-end.

- [ ] **Step 1: Run the full validator — expect all green**

```bash
bash tests/validate.sh
```

Expected: every line `PASS`, final `ALL CHECKS PASS` (exit 0). If any `FAIL`,
the corresponding task's file is missing a marker — fix before continuing.

- [ ] **Step 2: Create the fixture repo files**

Create `tests/fixtures/sample-repo/README.md`:

```markdown
# Sample Service

A demo HTTP service used to exercise the class-builder skill. It exposes a
single endpoint and protects it with a token-bucket rate limiter.
```

Create `tests/fixtures/sample-repo/NOTES.md`:

```markdown
# Notes index

- notes/rate-limiting.md — how the token-bucket rate limiter works and why we
  chose it over fixed-window.
```

Create `tests/fixtures/sample-repo/notes/rate-limiting.md`:

```markdown
# Rate limiting

We use a token-bucket algorithm. Each client gets a bucket of N tokens that
refills at R tokens/second. A request costs one token; an empty bucket returns
HTTP 429. Chosen over fixed-window because it smooths bursts without sharp
boundary spikes.
```

- [ ] **Step 3: Manual smoke test (record result)**

Install the skill and dry-run it against the fixture:

```bash
ln -sf "$PWD" ~/.claude/skills/class-builder
```

Then, in a Claude Code session, invoke `class-builder` pointed at
`tests/fixtures/sample-repo`. Confirm it: reads `NOTES.md` first, proposes
"rate limiting" as a topic, asks the four Step 1 inputs, and pauses for approval
after writing `00-objectives.md`. This is a manual check — note the outcome in
the commit message.

- [ ] **Step 4: Commit**

```bash
git add tests/fixtures
git commit -m "test: add fixture repo and confirm full validation passes"
```

---

## Self-Review notes

- **Spec coverage:** discover/NOTES-first (Task 2 Step 2, Step 0), four runtime
  inputs (Task 2), objectives + LO IDs + approval gate (Task 2), presentation
  rules incl. full speaker script (Task 4), lab structure + validation (Task 5),
  workbook 10 MCQ + 3 free-text + rubric + timing (Task 6), `*` convention +
  glossary (Task 7), output layout (Task 2, every template), Mermaid default
  (Tasks 3–4), packaging into SKILL.md + references/ (Tasks 2–7). All spec
  sections map to a task.
- **No placeholders:** every file's full content is inline.
- **Marker consistency:** the grep patterns in `tests/validate.sh` (Task 1)
  match the literal strings written in Tasks 2–7 (`name: class-builder`,
  `Step 0`, `[APPROVE]`, `speaker script`, `memoriz`, `250`, `Problem`,
  `mermaid`, `prerequisite`, `validation`, `multiple-choice`, `free-text`,
  `rubric`, `LO`, `glossary.md`).
```
