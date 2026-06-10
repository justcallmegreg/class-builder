# Presentation template

Output file: `workshops/<topic-slug>/01-presentation.md`.

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