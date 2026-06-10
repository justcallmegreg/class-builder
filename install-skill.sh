#!/usr/bin/env bash
# Install class-builder as a personal Claude Code skill by symlinking this
# repo into ~/.claude/skills/. Idempotent and safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS_DIR="${HOME}/.claude/skills"
LINK="${SKILLS_DIR}/class-builder"

mkdir -p "$SKILLS_DIR"

if [ -L "$LINK" ]; then
  current="$(readlink "$LINK")"
  if [ "$current" = "$REPO_DIR" ]; then
    echo "Already installed: $LINK -> $REPO_DIR"
    exit 0
  fi
  echo "Updating existing symlink ($current -> $REPO_DIR)"
  ln -sfn "$REPO_DIR" "$LINK"
elif [ -e "$LINK" ]; then
  echo "Refusing to overwrite non-symlink: $LINK" >&2
  echo "Remove it manually, then re-run." >&2
  exit 1
else
  ln -s "$REPO_DIR" "$LINK"
fi

echo "Installed: $LINK -> $REPO_DIR"
echo "Restart Claude Code (or start a new session) to pick up the skill."
