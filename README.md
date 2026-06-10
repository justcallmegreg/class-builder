# workshop-builder

A Claude Code skill that turns a repository into workshop teaching materials:
learning objectives, a short presentation (with full speaker scripts), a
lab/demo, and a workbook quiz — all as structured Markdown.

Grounded in pedagogy: constructive alignment, the 10/20/30 rule, Bloom's
taxonomy, and a Problem → Solution → Reasoning narrative arc.

## Install

Symlink this repo into your personal skills directory:

```bash
ln -s "$PWD" ~/.claude/skills/workshop-builder
```

Then invoke it in Claude Code by pointing it at a repository you want to teach.

## Validate

```bash
bash tests/validate.sh
```

## Design

See `docs/superpowers/specs/2026-06-10-workshop-builder-design.md`.
