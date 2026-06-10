---
name: class-builder
description: Use when turning a repository into class, workshop, or lab teaching materials — generates learning objectives, a 10-slide presentation with full memorizable speaker scripts, a lab/demo, and a workbook quiz as structured Markdown, grounded in pedagogy (constructive alignment, 10/20/30, Bloom, problem-solution-reasoning).
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

## Step 7 — Export to PDF (optional)

When the artifacts are ready to review, generate content-faithful review PDFs:

```bash
./export-pdf.sh classes/<topic-slug>
```

This runs `pandoc` over every top-level `.md` in the class directory and writes
PDFs to `classes/<topic-slug>/pdf/`. Mermaid is left as code (not rendered).
On-demand only — outside the `[APPROVE]`/`[REVIEW]` gates above. Requires
`pandoc` plus a PDF engine (`wkhtmltopdf` or `weasyprint`).

## Output layout

```
classes/<topic-slug>/
  00-objectives.md
  01-presentation.md
  02-lab.md
  03-workbook.md
  glossary.md
```
