#!/usr/bin/env bash
# install-framework.sh - Deterministic installation of AI Software Architect framework
#
# Handles all file operations for setup-architect skill:
#   1. Verify prerequisites (framework cloned, project markers)
#   2. Copy framework files from clone to .architecture/
#   3. Remove clone directory
#   4. Create directory structure
#   5. Initialize configuration from template
#   6. Cleanup framework docs and .git
#   7. Verify installation
#
# Usage: install-framework.sh <project-root>
#
# Arguments:
#   project-root  Absolute path to the target project root directory
#
# Exit codes:
#   0  Success - all steps completed
#   1  Prerequisites failed (framework not cloned or bad arguments)
#   2  Copy failed
#   3  Cleanup failed (safety check)
#   4  Verification failed (installation incomplete)
#
# Stdout: structured status tokens (one per line)
# Stderr: human-readable errors and warnings

set -euo pipefail

PROJECT_ROOT="${1:?Usage: install-framework.sh <project-root>}"

# Validate project root is absolute path
if [[ "$PROJECT_ROOT" != /* ]]; then
  echo "ERROR: project-root must be an absolute path: $PROJECT_ROOT" >&2
  exit 1
fi

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "ERROR: project root does not exist: $PROJECT_ROOT" >&2
  exit 1
fi

ARCH_DIR="$PROJECT_ROOT/.architecture"
CLONE_DIR="$ARCH_DIR/.architecture"
SOURCE_DIR="$CLONE_DIR/.architecture"

# --- Phase 1: Prerequisites ---

check_prerequisites() {
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Framework not found at $SOURCE_DIR" >&2
    echo "Clone first: git clone https://github.com/bettison-org/ai-software-architect $CLONE_DIR" >&2
    exit 1
  fi

  # Warn (don't fail) if no project markers found
  local has_marker=false
  for marker in package.json Gemfile requirements.txt go.mod Cargo.toml .git Makefile; do
    if [ -e "$PROJECT_ROOT/$marker" ]; then
      has_marker=true
      break
    fi
  done

  if [ "$has_marker" = false ]; then
    echo "WARNING: No project markers found in $PROJECT_ROOT" >&2
  fi

  echo "PREREQ_OK"
}

# --- Phase 2: Install ---

copy_framework() {
  if ! cp -r "$SOURCE_DIR"/* "$ARCH_DIR"/ 2>&2; then
    echo "ERROR: Failed to copy framework files from $SOURCE_DIR to $ARCH_DIR" >&2
    exit 2
  fi
  echo "COPY_OK"
}

remove_clone() {
  rm -rf "$CLONE_DIR"
  if [ ! -d "$CLONE_DIR" ]; then
    echo "CLONE_REMOVED"
  else
    echo "WARNING: Clone directory still exists: $CLONE_DIR" >&2
  fi
}

create_directories() {
  mkdir -p "$PROJECT_ROOT/.coding-assistants/claude"
  mkdir -p "$PROJECT_ROOT/.coding-assistants/cursor"
  mkdir -p "$PROJECT_ROOT/.coding-assistants/codex"
  mkdir -p "$ARCH_DIR/decisions/adrs"
  mkdir -p "$ARCH_DIR/reviews"
  mkdir -p "$ARCH_DIR/recalibration"
  mkdir -p "$ARCH_DIR/comparisons"
  mkdir -p "$ARCH_DIR/agent_docs"
  echo "DIRS_OK"
}

init_config() {
  if [ -f "$ARCH_DIR/templates/config.yml" ] && [ ! -f "$ARCH_DIR/config.yml" ]; then
    cp "$ARCH_DIR/templates/config.yml" "$ARCH_DIR/config.yml"
    echo "CONFIG_INIT"
  elif [ -f "$ARCH_DIR/config.yml" ]; then
    echo "CONFIG_EXISTS"
  else
    echo "WARNING: No config template found at $ARCH_DIR/templates/config.yml" >&2
    echo "CONFIG_NO_TEMPLATE"
  fi
}

# --- Phase 3: Cleanup ---

cleanup_docs() {
  rm -f "$ARCH_DIR/README.md"
  rm -f "$ARCH_DIR"/USAGE*.md
  rm -f "$ARCH_DIR/INSTALL.md"
  echo "CLEANUP_DOCS_OK"
}

cleanup_git() {
  local git_dir="$ARCH_DIR/.git"

  # Check target exists
  if [ ! -d "$git_dir" ]; then
    echo "CLEANUP_GIT_NOT_FOUND"
    return 0
  fi

  # Allow skipping for testing
  if [ "${SKIP_GIT_CLEANUP:-0}" = "1" ]; then
    echo "CLEANUP_GIT_SKIPPED"
    return 0
  fi

  # Safeguard 1: verify it's the template repo
  if ! grep -q "ai-software-architect" "$git_dir/config" 2>/dev/null; then
    echo "ERROR: $git_dir does not appear to be the template repository" >&2
    echo "ERROR: Refusing to remove - manual verification required" >&2
    exit 3
  fi

  # Safeguard 2: get absolute path and verify pattern
  local abs_git_dir
  abs_git_dir="$(cd "$ARCH_DIR" && pwd)/.git"
  if [[ "$abs_git_dir" != *"/.architecture/.git" ]]; then
    echo "ERROR: Path does not match expected pattern: $abs_git_dir" >&2
    exit 3
  fi

  # Safeguard 3: execute removal with absolute path, no wildcards
  rm -rf "$abs_git_dir"

  if [ ! -d "$git_dir" ]; then
    echo "CLEANUP_GIT_OK"
  else
    echo "ERROR: Failed to remove $git_dir" >&2
    exit 3
  fi
}

# --- Phase 4: Verify ---

verify_installation() {
  local missing=()

  [ -d "$ARCH_DIR/decisions/adrs" ] || missing+=("decisions/adrs")
  [ -d "$ARCH_DIR/reviews" ] || missing+=("reviews")
  [ -d "$ARCH_DIR/recalibration" ] || missing+=("recalibration")
  [ -d "$ARCH_DIR/agent_docs" ] || missing+=("agent_docs")
  [ -d "$ARCH_DIR/templates" ] || missing+=("templates")
  [ -f "$ARCH_DIR/members.yml" ] || missing+=("members.yml")
  [ -f "$ARCH_DIR/principles.md" ] || missing+=("principles.md")

  if [ ${#missing[@]} -gt 0 ]; then
    echo "ERROR: Installation incomplete. Missing: ${missing[*]}" >&2
    exit 4
  fi

  # Report what was installed
  local installed=()
  [ -f "$ARCH_DIR/members.yml" ] && installed+=("members.yml")
  [ -f "$ARCH_DIR/principles.md" ] && installed+=("principles.md")
  [ -f "$ARCH_DIR/config.yml" ] && installed+=("config.yml")
  [ -d "$ARCH_DIR/templates" ] && installed+=("templates/")
  [ -d "$ARCH_DIR/agent_docs" ] && installed+=("agent_docs/")
  [ -d "$ARCH_DIR/decisions/adrs" ] && installed+=("decisions/adrs/")
  [ -d "$ARCH_DIR/reviews" ] && installed+=("reviews/")

  echo "VERIFY_OK"
  echo "INSTALLED:$(IFS=,; echo "${installed[*]}")"
}

# --- Execute ---

check_prerequisites
copy_framework
remove_clone
create_directories
init_config
cleanup_docs
cleanup_git
verify_installation
