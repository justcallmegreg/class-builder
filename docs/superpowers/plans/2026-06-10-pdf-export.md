# PDF Export for class-builder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an on-demand `export-pdf.sh` to the class-builder skill that converts a class directory's Markdown artifacts into content-faithful review PDFs via Pandoc.

**Architecture:** A standalone Bash script at the repo root (beside `install-skill.sh`) shells out to `pandoc` for every top-level `*.md` in a given class directory, writing PDFs to a `pdf/` subfolder. It auto-detects a PDF engine (`wkhtmltopdf` then `weasyprint`) and fails fast with install hints if the toolchain is missing. A behavioral test exercises argument handling and (when the toolchain is present) real conversion; the existing structural validator gains two presence checks; `SKILL.md` and `README.md` document the new step.

**Tech Stack:** Bash, Pandoc, a PDF engine (wkhtmltopdf or weasyprint). No new language runtimes.

Spec reference: `docs/superpowers/specs/2026-06-10-pdf-export-design.md`.

---

## File Structure

- `export-pdf.sh` (new, repo root) — the converter. One responsibility: turn a class dir's `*.md` into `pdf/*.pdf`.
- `tests/test-export-pdf.sh` (new) — behavioral test: no-arg usage + conditional real conversion.
- `tests/validate.sh` (modify) — add two structural checks (script present, SKILL.md mentions it).
- `SKILL.md` (modify) — add **Step 7 — Export to PDF (optional)** before the Output layout section.
- `README.md` (modify) — add an **Export to PDF** section before Repository structure.

---

## Task 1: The `export-pdf.sh` converter (TDD)

**Files:**
- Create: `export-pdf.sh`
- Create: `tests/test-export-pdf.sh`

- [ ] **Step 1: Write the failing behavioral test**

Create `tests/test-export-pdf.sh` with EXACTLY this content:

```bash
#!/usr/bin/env bash
# Behavioral test for export-pdf.sh.
set -u
cd "$(dirname "$0")/.."

SCRIPT="./export-pdf.sh"
fail=0

# Test 1: no arguments -> non-zero exit and a usage message on stderr.
if out="$("$SCRIPT" 2>&1)"; then
  echo "FAIL  no-arg invocation should exit non-zero"
  fail=1
elif printf '%s' "$out" | grep -qi "usage"; then
  echo "PASS  no-arg invocation exits non-zero with usage"
else
  echo "FAIL  no-arg invocation did not print usage (got: $out)"
  fail=1
fi

# Test 2: real conversion -- only when pandoc + a PDF engine are present.
engine=""
for c in wkhtmltopdf weasyprint; do
  if command -v "$c" >/dev/null 2>&1; then engine="$c"; break; fi
done
if command -v pandoc >/dev/null 2>&1 && [ -n "$engine" ]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  printf '# Sample\n\nHello, world.\n' > "$tmp/sample.md"
  "$SCRIPT" "$tmp" >/dev/null
  if [ -f "$tmp/pdf/sample.pdf" ] && head -c 4 "$tmp/pdf/sample.pdf" | grep -qa '%PDF'; then
    echo "PASS  converts markdown to a valid PDF"
  else
    echo "FAIL  expected $tmp/pdf/sample.pdf starting with %PDF"
    fail=1
  fi
else
  echo "SKIP  pandoc/engine not installed -- conversion test skipped"
fi

echo "----"
if [ "$fail" -eq 0 ]; then echo "ALL EXPORT TESTS PASS"; else echo "SOME EXPORT TESTS FAILED"; fi
exit "$fail"
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
chmod +x tests/test-export-pdf.sh && bash tests/test-export-pdf.sh
```

Expected: `FAIL  no-arg invocation did not print usage` (the script doesn't exist yet, so invoking it errors with "No such file or directory" rather than a usage line), final `SOME EXPORT TESTS FAILED`, exit 1.

- [ ] **Step 3: Implement `export-pdf.sh`**

Create `export-pdf.sh` with EXACTLY this content:

```bash
#!/usr/bin/env bash
# Export a class directory's Markdown artifacts to content-faithful review PDFs
# using pandoc. Mermaid fences are left as code blocks (not rendered).
set -euo pipefail

usage() {
  echo "Usage: $0 <class-dir>" >&2
  echo "  Converts every top-level *.md in <class-dir> to <class-dir>/pdf/<name>.pdf" >&2
}

# --- Argument validation ---
if [ "$#" -ne 1 ]; then
  usage
  exit 2
fi

CLASS_DIR="$1"
if [ ! -d "$CLASS_DIR" ]; then
  echo "Error: not a directory: $CLASS_DIR" >&2
  usage
  exit 2
fi

# Collect top-level markdown files (non-recursive).
shopt -s nullglob
md_files=("$CLASS_DIR"/*.md)
shopt -u nullglob
if [ "${#md_files[@]}" -eq 0 ]; then
  echo "Error: no top-level .md files in $CLASS_DIR" >&2
  exit 2
fi

# --- Preflight: pandoc + a PDF engine (fail fast, no partial output) ---
if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc not found. Install it: brew install pandoc" >&2
  exit 1
fi

ENGINE=""
for candidate in wkhtmltopdf weasyprint; do
  if command -v "$candidate" >/dev/null 2>&1; then
    ENGINE="$candidate"
    break
  fi
done
if [ -z "$ENGINE" ]; then
  echo "Error: no PDF engine found. Install one:" >&2
  echo "  brew install wkhtmltopdf   # or:  pip install weasyprint" >&2
  exit 1
fi

# --- Convert ---
OUT_DIR="$CLASS_DIR/pdf"
mkdir -p "$OUT_DIR"

count=0
for md in "${md_files[@]}"; do
  name="$(basename "$md" .md)"
  out="$OUT_DIR/$name.pdf"
  pandoc "$md" --pdf-engine="$ENGINE" -o "$out"
  echo "  wrote $out"
  count=$((count + 1))
done

echo "Done: $count PDF(s) in $OUT_DIR (engine: $ENGINE)"
```

- [ ] **Step 4: Make it executable and run the test to verify it passes**

```bash
chmod +x export-pdf.sh && bash tests/test-export-pdf.sh
```

Expected: `PASS  no-arg invocation exits non-zero with usage`, then either `PASS  converts markdown to a valid PDF` (if pandoc+engine are installed) or `SKIP  pandoc/engine not installed -- conversion test skipped`, final `ALL EXPORT TESTS PASS`, exit 0.

- [ ] **Step 5: Commit**

```bash
git add export-pdf.sh tests/test-export-pdf.sh
git commit -m "feat: add export-pdf.sh to render class markdown to review PDFs"
```

---

## Task 2: Integrate into validator, SKILL.md, and README

**Files:**
- Modify: `tests/validate.sh`
- Modify: `SKILL.md`
- Modify: `README.md`

- [ ] **Step 1: Add two structural checks to `tests/validate.sh`**

In `tests/validate.sh`, find the glossary block:

```bash
# glossary-rules.md
check "glossary asterisk rule" references/glossary-rules.md "trailing .\*. |every use|every occurrence"
check "glossary file"          references/glossary-rules.md "glossary.md"
```

Insert the following block immediately AFTER those two lines (before the `echo "----"` line):

```bash

# export-pdf.sh + integration
check "export script (pandoc)" export-pdf.sh "pandoc"
check "SKILL export step"      SKILL.md "export-pdf.sh"
```

- [ ] **Step 2: Run the validator to verify the new SKILL check fails**

```bash
bash tests/validate.sh | grep -E "export script|SKILL export"
```

Expected: `PASS  export script (pandoc)` (the script exists from Task 1) and `FAIL  SKILL export step` (SKILL.md doesn't mention it yet).

- [ ] **Step 3: Add Step 7 to `SKILL.md`**

In `SKILL.md`, find this exact text (end of Step 6 followed by the Output layout heading):

````
Collect every `*`-marked short form into the canonical resolution table.
Follow `references/glossary-rules.md`.

## Output layout
````

Replace it with:

````
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
````

- [ ] **Step 4: Add an Export to PDF section to `README.md`**

In `README.md`, find this exact line:

```
## Repository structure
```

Replace it with:

````
## Export to PDF

Generate content-faithful review PDFs of a class's Markdown (one per artifact)
before you build the real materials:

```bash
./export-pdf.sh classes/<topic-slug>
```

PDFs are written to `classes/<topic-slug>/pdf/`. Mermaid diagrams are left as
code blocks (not rendered). Requires `pandoc` and a PDF engine:

```bash
brew install pandoc
brew install wkhtmltopdf   # or:  pip install weasyprint
```

## Repository structure
````

- [ ] **Step 5: Run the full validator to verify everything passes**

```bash
bash tests/validate.sh
```

Expected: every line `PASS` (23 checks: the original 21 plus the 2 new ones), final `ALL CHECKS PASS`, exit 0.

- [ ] **Step 6: Commit**

```bash
git add tests/validate.sh SKILL.md README.md
git commit -m "feat: document and validate the PDF export step"
```

---

## Self-Review notes

- **Spec coverage:** `export-pdf.sh` with arg validation + no-`.md` guard (Task 1 Step 3); preflight pandoc + engine auto-detect wkhtmltopdf→weasyprint with fail-fast install hints (Task 1 Step 3); convert all top-level `.md` into `pdf/` (Task 1 Step 3); SKILL.md Step 7 framed on-demand/outside gates (Task 2 Step 3); README Export section with prerequisites (Task 2 Step 4); validate.sh presence checks (Task 2 Step 1); behavioral test with `%PDF` assertion and SKIP-without-toolchain (Task 1 Step 1). All spec sections map to a task. Out-of-scope items (styling, slides, Mermaid rendering, auto-run) are not implemented — correct.
- **No placeholders:** every file's full content / exact edit is inline.
- **Consistency:** the engine-detection order (`wkhtmltopdf` then `weasyprint`), the `pdf/` output subdir, and the `<class-dir>/pdf/<name>.pdf` naming are identical across `export-pdf.sh`, `tests/test-export-pdf.sh`, `SKILL.md`, and `README.md`. The validate.sh check greps `export-pdf.sh` for the literal string `pandoc` (present) and `SKILL.md` for the literal string `export-pdf.sh` (added in Task 2 Step 3).
