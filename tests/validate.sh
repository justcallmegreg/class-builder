#!/usr/bin/env bash
# Structural validator for the class-builder skill.
# Each check greps a required marker in a target file. Prints PASS/FAIL per
# check and exits non-zero if any check fails.
set -u
cd "$(dirname "$0")/.." || exit 2

fail=0
check() { # check <description> <file> <grep-pattern>
  if [ -f "$2" ] && grep -qiE "$3" "$2"; then
    echo "PASS  $1"
  else
    echo "FAIL  $1"
    fail=1
  fi
}

# SKILL.md
check "SKILL frontmatter name"        SKILL.md "^name: class-builder"
check "SKILL frontmatter description" SKILL.md "^description: .+"
check "SKILL step 0 discover"         SKILL.md "Step 0"
check "SKILL step 6 glossary"         SKILL.md "Step 6"
check "SKILL approval checkpoint"     SKILL.md "\[APPROVE\]"

# pedagogy.md
check "pedagogy constructive alignment" references/pedagogy.md "constructive alignment"
check "pedagogy bloom"                   references/pedagogy.md "bloom"
check "pedagogy 10/20/30"                references/pedagogy.md "10/20/30"

# presentation-template.md
check "presentation speaker script"   references/presentation-template.md "speaker script"
check "presentation memorizable"      references/presentation-template.md "memoriz"
check "presentation word budget"      references/presentation-template.md "250"
check "presentation arc"              references/presentation-template.md "Problem"
check "presentation mermaid"          references/presentation-template.md "mermaid"

# lab-template.md
check "lab prerequisites" references/lab-template.md "prerequisite"
check "lab validation"    references/lab-template.md "validation|how to know"

# workbook-template.md
check "workbook 10 mcq"     references/workbook-template.md "multiple-choice"
check "workbook 3 freetext" references/workbook-template.md "free-text"
check "workbook rubric"     references/workbook-template.md "rubric"
check "workbook LO tag"     references/workbook-template.md "LO"

# glossary-rules.md
check "glossary asterisk rule" references/glossary-rules.md "trailing .\*. |every use|every occurrence"
check "glossary file"          references/glossary-rules.md "glossary.md"

echo "----"
if [ "$fail" -eq 0 ]; then echo "ALL CHECKS PASS"; else echo "SOME CHECKS FAILED"; fi
exit "$fail"
