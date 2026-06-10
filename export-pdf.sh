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
