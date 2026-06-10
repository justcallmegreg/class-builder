# Workshop Builder Skill — Design Spec

**Date:** 2026-06-10
**Status:** Draft for review
**Working name:** `workshop-builder`

## Purpose

A Claude Code skill that turns an existing repository into a coherent set of
teaching materials for a workshop or lab: a short presentation, a lab/demo, and
a workbook (quiz/exam). The skill reads the repo's own knowledge (code, docs,
notes) and produces all materials as structured **Markdown** — content the
author finishes manually (e.g. building the actual slides), not finished
artifacts.

The skill is grounded in established pedagogy so the three artifacts stay
coherent and actually teach, rather than just summarizing.

## Pedagogical foundations

These principles are encoded into the skill's rules and templates:

- **Constructive alignment (Biggs)** — derive learning objectives first; every
  downstream slide, lab step, and quiz question references the objective it
  serves. This is the connective tissue that keeps three artifacts coherent and
  makes coverage gaps visible.
- **Problem → Solution → Reasoning arc** — the narrative spine of the
  presentation (maps to Sinek's Why/What/How and problem-based learning).
- **10/20/30 rule (Kawasaki)** — 10 slides max, 20 minutes max, 30pt font.
- **Mayer's multimedia principles + dual coding** — minimize text, prefer
  visuals; diagrams default to Mermaid (markdown-native).
- **Cognitive load theory** — one idea per slide, plain clean English.
- **Bloom's taxonomy** — workbook questions target *Understand / Apply /
  Analyze* (conceptual), not *Remember* (recall).
- **Experiential learning (Kolb) + worked examples** — the lab/demo is the
  concrete "do" phase; who executes it (presenter vs. audience) is irrelevant to
  its pedagogical role.
- **Retrieval practice** — the workbook is the retrieval step that cements
  learning.

## Runtime behavior — staged with checkpoints

The skill runs as a staged workflow with review checkpoints between artifacts,
so the author can correct the objectives before they propagate into three
artifacts.

```
Step 0  Discover   → scan README.md, docs/, notes/ + NOTES.md (index), code
Step 1  Gather     → ask: topic/scope, audience level, lab style, prior knowledge
Step 2  Objectives → 3–5 Bloom-tagged learning objectives (LO1…LOn)  → 00-objectives.md  [APPROVE]
Step 3  Present    → 10-slide deck content                           → 01-presentation.md [REVIEW]
Step 4  Lab        → demo/hands-on lab                               → 02-lab.md          [REVIEW]
Step 5  Workbook   → 10 MCQ + 3 free-text                            → 03-workbook.md      [REVIEW]
Step 6  Glossary   → collect every *-marked term                     → glossary.md
```

### Step 0 — Discover

Scan the repository to build a picture of its content. **`NOTES.md` is read
first** — it is the author's AI-friendly index of what notes exist, so the skill
uses it to shortlist candidate topics rather than blindly scanning everything.
Sources, in priority order:

1. `NOTES.md` (index of `notes/`)
2. `notes/`
3. `docs/`
4. `README.md`
5. code structure

### Step 1 — Gather inputs

Ask the author for (proposing sensible defaults/candidates where possible):

- **Topic / scope** — which subject within the repo to teach. The skill proposes
  candidate topics derived from `NOTES.md`/`docs/`/`README.md`; the author picks
  or refines.
- **Audience level** — beginner / intermediate / advanced. Drives Bloom level,
  depth, and assumed background.
- **Lab style** — hands-on (audience executes) vs. presenter demo. Affects only
  the *phrasing* of lab steps, not their structure.
- **Prior knowledge** — what the audience already knows, so prerequisites are
  compressed or skipped rather than re-taught.

### Step 2 — Learning objectives → `00-objectives.md`  *(approval checkpoint)*

Produce 3–5 learning objectives, each:

- written with a Bloom action verb appropriate to the audience level,
- assigned a stable ID (`LO1`, `LO2`, …).

These IDs are referenced by every downstream artifact. **The author approves the
objectives before generation continues.**

### Step 3 — Presentation → `01-presentation.md`  *(review checkpoint)*

- **10 slides max**, bucketed into the **Problem → Solution → Reasoning** arc
  (roughly 3 / 4 / 3 slides).
- A header reminder carries the 20-min / 30pt-font constraints (this is slide
  *content*, not a built deck).
- Plain, clean English; one idea per slide.
- Abbreviations marked with the `*` convention (see Glossary section).
- Diagrams default to **Mermaid**; if a visual isn't diagrammable, describe it.
- Each slide is a structured block:

```
## Slide 3 — The cost of manual scaling   [LO1]
**Purpose:** establish the pain
**Content:**
- bullet, plain English, one idea
**Visual:** ```mermaid``` diagram (or described if not diagrammable)
**Speaker script:** Full spoken narrative for this slide.
```

- **Speaker script is a full, memorizable commentary** — continuous spoken-word
  prose (~250–300 words ≈ ~2 min per slide), **not** bullet reminders. It must:
  - flow in the same plain, clean English as the slides,
  - carry that slide's Problem/Solution/Reasoning beat,
  - **transition into the next slide** so the talk feels continuous,
  - stay within the slide's share of the 20-minute budget (so the deck still
    obeys 10/20/30).

### Step 4 — Lab → `02-lab.md`  *(review checkpoint)*

Lab style (demo vs. hands-on) is set in Step 1 and changes only phrasing
(copy-paste-ready commands vs. narrated walkthrough). Structure either way:

- Prerequisites & setup
- Steps — each tagged with the LO it reinforces
- Expected outcome / how to know it worked (validation)
- Stretch / optional steps

### Step 5 — Workbook → `03-workbook.md`  *(review checkpoint)*

- **10 multiple-choice questions** — conceptual (Bloom *Understand / Apply /
  Analyze*, never recall). Each has 1 correct answer + plausible distractors.
  An **answer key with a one-line rationale per question** lives in a separate
  appendix/collapsed section so the student copy is clean.
- **3 free-text questions** — tutor-reviewed. Each carries a short **grading
  rubric** (what a good answer contains) so tutoring is consistent.
- Every question tagged with its LO.
- Timing budget shown up front:
  `10 × (1–2 min) + 3 × (up to 5 min) ≈ 25–35 min`.

### Step 6 — Glossary → `glossary.md`

Collect every `*`-marked short form into a canonical resolution table.

## Output layout

A self-contained folder per workshop, keeping generated teaching material
separate from the source repo's own docs:

```
workshops/<topic-slug>/
  00-objectives.md
  01-presentation.md
  02-lab.md
  03-workbook.md
  glossary.md
```

## The `*` abbreviation convention

- Every short form is written with a trailing `*` at **every** use (not just
  first use) — slides may be shown out of order, so each occurrence is
  self-flagging: `AWS*`, `IAM*`.
- `glossary.md` is the canonical resolution table, accumulated across all
  artifacts: `AWS* → Amazon Web Services`.

## Skill packaging

A single skill built per Superpowers `writing-skills` conventions. Templates
live in `references/` so `SKILL.md` stays lean and only the relevant template is
pulled per artifact.

```
workshop-builder/
  SKILL.md                    # the staged workflow + pedagogical rules
  references/
    pedagogy.md               # Bloom verbs, alignment rules, the "why" per rule
    presentation-template.md  # slide block format + full-commentary speaker rule
    lab-template.md
    workbook-template.md
    glossary-rules.md         # the * abbreviation convention
```

## Key conventions (settled judgment calls)

- **Diagram format:** Mermaid by default.
- **Abbreviations:** mark every occurrence with `*`; resolve in `glossary.md`.
- **Speaker notes:** full memorizable commentary (~250–300 words/slide), not
  bullets.
- **Alignment:** objectives carry IDs; every slide / lab step / quiz question is
  tagged with the LO it serves.

## Out of scope

- Rendering actual slide decks (PowerPoint/Reveal.js/etc.) — output is Markdown
  content only.
- Auto-grading free-text answers — those are tutor-reviewed by design.
- Multi-topic batch generation — one topic per run (run again for another).
```
