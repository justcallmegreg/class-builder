# workshop-builder

A Claude Code skill that turns a repository into a complete, teachable workshop —
**learning objectives**, a short **presentation** (with full memorizable speaker
scripts), a **lab/demo**, and a **workbook** quiz — all as structured Markdown
you finish by hand.

It reads what the repo already knows (`README.md`, `docs/`, `notes/`, and a
`NOTES.md` index), then generates aligned teaching materials grounded in
established pedagogy rather than ad-hoc summaries.

## Why

Most "explain this repo" output is a flat summary. Teaching is different: it
needs objectives, a narrative, a hands-on step, and a way to check understanding —
all pointing at the same goals. workshop-builder encodes that discipline:

- **Constructive alignment** — objectives are derived first; every slide, lab
  step, and quiz question is tagged with the objective (`LOx`) it serves, so the
  four artifacts can't drift apart.
- **Problem → Solution → Reasoning** — the presentation's narrative spine: the
  pain first, then the fix, then why it works.
- **10/20/30 rule** — 10 slides max, ~20 minutes, 30pt font. Ruthless brevity.
- **Bloom's taxonomy** — workbook questions test *understanding and application*,
  not factual recall.
- **Visual-first** — diagrams default to Mermaid (markdown-native).

See `references/pedagogy.md` for the full rationale.

## How it works

Run as a **staged workflow with checkpoints** — you approve the objectives
before they propagate into three artifacts, and review each artifact as it lands:

```
Step 0  Discover   scan NOTES.md (first), notes/, docs/, README.md, code
Step 1  Gather     ask: topic/scope · audience level · lab style · prior knowledge
Step 2  Objectives 3–5 Bloom-tagged objectives (LO1…LOn)   → 00-objectives.md  [APPROVE]
Step 3  Present     10-slide deck + full speaker scripts    → 01-presentation.md [REVIEW]
Step 4  Lab         demo or hands-on, with validation       → 02-lab.md          [REVIEW]
Step 5  Workbook    10 MCQ + 3 free-text (rubric-graded)    → 03-workbook.md      [REVIEW]
Step 6  Glossary    every *-marked abbreviation, resolved   → glossary.md
```

### Output layout

One self-contained folder per workshop:

```
workshops/<topic-slug>/
  00-objectives.md
  01-presentation.md
  02-lab.md
  03-workbook.md
  glossary.md
```

### What each artifact contains

- **Presentation** — one structured block per slide (purpose, content bullets, a
  Mermaid visual, and a *full memorizable speaker script* of ~250–300 words that
  carries the narrative and transitions into the next slide). Abbreviations are
  marked with a trailing `*` (e.g. `AWS*`) and resolved in the glossary.
- **Lab** — prerequisites, LO-tagged steps, and a validation section so success
  is observable. Works as a presenter demo or a hands-on exercise — only the
  phrasing changes.
- **Workbook** — 10 conceptual multiple-choice questions plus 3 tutor-reviewed
  free-text questions (each with a grading rubric), an instructor answer key in a
  separate appendix, and a timing budget (~25–35 min).

## Install

Run the install script — it symlinks this repo into your personal skills
directory (`~/.claude/skills/`) and is safe to re-run:

```bash
./install-skill.sh
```

Restart Claude Code (or start a new session) to pick up the skill, then point it
at a repository you want to teach.

## Usage

Invoke the skill and tell it which repo (and, if you like, the topic). It will
ask for the audience level, lab style, and assumed prior knowledge, then walk the
staged workflow above — pausing for your approval on the objectives and a review
on each artifact.

Try it against the bundled fixture to see the full flow on a tiny example:

```
tests/fixtures/sample-repo/
```

It should read `NOTES.md` first, propose "rate limiting" as the topic, ask the
four inputs, and pause after writing `00-objectives.md`.

## Repository structure

```
SKILL.md                       the staged workflow + rules (the skill entry point)
references/
  pedagogy.md                  the teaching principles behind every rule
  presentation-template.md     slide-block format + speaker-script rule
  lab-template.md              lab/demo structure
  workbook-template.md         quiz format, rubrics, timing
  glossary-rules.md            the * abbreviation convention
tests/
  validate.sh                  structural validator (run to check the skill)
  fixtures/sample-repo/        tiny repo for an end-to-end smoke test
docs/superpowers/
  specs/                       design spec
  plans/                       implementation plan
```

## Validate

`tests/validate.sh` structurally checks the skill (frontmatter + required section
markers in every file):

```bash
bash tests/validate.sh
```

Expected: `ALL CHECKS PASS`.

## Design & plan

- Spec: `docs/superpowers/specs/2026-06-10-workshop-builder-design.md`
- Plan: `docs/superpowers/plans/2026-06-10-workshop-builder.md`
