# Glossary rules — the `*` abbreviation convention

Output file: `workshops/<topic-slug>/glossary.md`.

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
