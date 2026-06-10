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
