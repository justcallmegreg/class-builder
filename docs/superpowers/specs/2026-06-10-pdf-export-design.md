# PDF Export for class-builder — Design Spec

**Date:** 2026-06-10
**Status:** Draft for review
**Component:** `export-pdf.sh` (added to the existing `class-builder` skill)

## Purpose

After `class-builder` generates a class's Markdown artifacts, the author wants
**content-faithful PDFs for review** — a quick way to read the objectives,
presentation, lab, workbook, and glossary as PDFs before doing the manual work
of building real slides/materials.

The goal is *readable and accurate*, not styled or presentation-ready. No
themes, no slide-deck layout, no diagram rendering.

## Scope decisions (settled)

- **Format:** document-style PDF, one pipeline for every artifact. No slide
  tooling.
- **Mermaid:** left as monospace code blocks (not rendered as images). This is
  what lets the simplest converter work.
- **Converter:** Pandoc. Claude Code has no built-in PDF generator; the native
  pattern is the skill shelling out to a CLI converter, and Pandoc is the
  canonical document converter.
- **PDF engine:** auto-detect `wkhtmltopdf`, then `weasyprint`. Error if neither
  is present (avoids a heavyweight LaTeX install). The script never
  auto-installs anything.
- **Which files:** export *all* top-level `.md` files in the class directory, so
  all five artifacts are covered and nothing is missed by a hard-coded list.
- **Output location:** a `pdf/` subfolder inside the class directory, keeping
  source Markdown and generated PDFs separate.
- **Trigger:** an on-demand script the author runs when ready to review. NOT
  part of the staged generation flow or its review gates.

## Component: `export-pdf.sh`

Lives at the repo root, beside `install-skill.sh`.

### Usage

```
./export-pdf.sh <class-dir>
```

Example: `./export-pdf.sh classes/token-bucket-rate-limiting`

### Behavior

1. **Argument validation.** If no argument is given, or the argument is not a
   directory, print a usage line to stderr and exit non-zero. If the directory
   contains no top-level `.md` files, print a clear message and exit non-zero.
2. **Preflight (fail fast, no partial output).**
   - If `pandoc` is not on `PATH`, print a one-line install hint
     (`brew install pandoc`) and exit non-zero.
   - Detect a PDF engine in order: `wkhtmltopdf`, then `weasyprint`. If neither
     is found, print a one-line install hint
     (`brew install wkhtmltopdf` or `pip install weasyprint`) and exit non-zero.
3. **Convert.** `mkdir -p <class-dir>/pdf`, then for each top-level `*.md`:
   ```
   pandoc "<class-dir>/<name>.md" --pdf-engine=<engine> -o "<class-dir>/pdf/<name>.pdf"
   ```
   Mermaid fences pass through as monospace code blocks (no rendering).
4. **Report.** Print each PDF as it is produced, and a final count summary.

### Conventions

- `set -euo pipefail`; quote all paths (class slugs and `$HOME` may contain
  spaces); resolve the engine once and reuse it.
- Idempotent: re-running overwrites the PDFs in `pdf/`.

## Skill & documentation integration

- **`SKILL.md`** gains **Step 7 — Export to PDF (optional)**: a short note that,
  once review-ready artifacts exist, `./export-pdf.sh <class-dir>` produces
  review PDFs under `pdf/`. Explicitly on-demand — outside the `[APPROVE]` /
  `[REVIEW]` gates of Steps 2–6.
- **`README.md`** gains an **Export to PDF** section documenting the command and
  the Pandoc + PDF-engine prerequisite (with the `brew`/`pip` install lines).

## Validation & testing

Consistent with the existing structural harness.

- **`tests/validate.sh`** gains two structural checks:
  - `export-pdf.sh` exists.
  - `SKILL.md` mentions the export step (e.g. matches `export-pdf.sh`).
- **`tests/test-export-pdf.sh`** (new behavioral test):
  - Running `export-pdf.sh` with no arguments exits non-zero and prints usage.
  - If `pandoc` and an engine are available: create a temp directory with a
    small sample `.md`, run the script, and assert the output file exists and
    begins with the `%PDF` magic bytes. If pandoc or an engine is missing, print
    `SKIP: pandoc/engine not installed` and pass — so the suite stays green on
    machines without the toolchain while genuinely testing conversion where it
    is available.

## Out of scope

- Styling, themes, or CSS.
- Slide-deck layout (one-slide-per-page, 30pt font, presenter notes).
- Rendering Mermaid diagrams as images.
- Auto-running export as part of the staged generation workflow.
- Output formats other than PDF (PPTX, DOCX, HTML).
