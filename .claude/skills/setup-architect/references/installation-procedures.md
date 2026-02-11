# Installation Procedures

This document provides troubleshooting, recovery, and reference information for the AI Software Architect framework installation.

**Note**: All file operations (copy, directory creation, cleanup) are handled by the `install-framework.sh` script. This document covers what the script does, how to troubleshoot failures, and how to recover from errors.

## Table of Contents

1. [What the Script Handles](#what-the-script-handles)
2. [Script Interface](#script-interface)
3. [Troubleshooting](#troubleshooting)
4. [Recovery](#recovery)
5. [Post-Installation](#post-installation)

---

## What the Script Handles

The `install-framework.sh` script at `scripts/install-framework.sh` performs all deterministic file operations in sequence:

1. **Prerequisites** — Verifies `.architecture/.architecture/.architecture/` exists (the cloned framework). Warns if no project markers found.
2. **Copy** — `cp -r .architecture/.architecture/.architecture/* .architecture/` copies only the framework template files.
3. **Remove clone** — `rm -rf .architecture/.architecture` removes the temporary clone directory.
4. **Create directories** — Creates all required directories: `.coding-assistants/claude`, `.coding-assistants/cursor`, `.coding-assistants/codex`, `.architecture/decisions/adrs`, `.architecture/reviews`, `.architecture/recalibration`, `.architecture/comparisons`, `.architecture/agent_docs`.
5. **Initialize config** — Copies `templates/config.yml` to `config.yml` if no config exists yet.
6. **Cleanup docs** — Removes framework documentation files (`README.md`, `USAGE*.md`, `INSTALL.md`) from `.architecture/`.
7. **Cleanup .git** — Safely removes the template repository's `.git/` directory using layered safeguards:
   - Verifies it's the template repo (checks `ai-software-architect` in `.git/config`)
   - Uses absolute path and verifies path pattern ends with `/.architecture/.git`
   - No wildcards in the `rm` command
   - Verifies removal succeeded
8. **Verify** — Checks all required files and directories exist.

---

## Script Interface

```
Usage: install-framework.sh <project-root>

Arguments:
  project-root    Absolute path to the target project root directory

Environment variables:
  SKIP_GIT_CLEANUP=1    Skip .git directory removal (for testing)

Exit codes:
  0  Success
  1  Prerequisites failed (framework not cloned, bad path)
  2  Copy failed
  3  Cleanup safety check failed
  4  Verification failed (installation incomplete)

Stdout tokens:
  PREREQ_OK           Prerequisites verified
  COPY_OK             Framework files copied
  CLONE_REMOVED       Clone directory removed
  DIRS_OK             Directory structure created
  CONFIG_INIT         Config initialized from template
  CONFIG_EXISTS       Config already existed (not overwritten)
  CONFIG_NO_TEMPLATE  No config template found
  CLEANUP_DOCS_OK     Framework docs removed
  CLEANUP_GIT_OK      Template .git removed
  CLEANUP_GIT_NOT_FOUND  No .git to remove
  CLEANUP_GIT_SKIPPED    Skipped (SKIP_GIT_CLEANUP=1)
  VERIFY_OK           Installation verified
  INSTALLED:<list>    Comma-separated list of installed components
```

---

## Troubleshooting

### Common Issues

**"Framework not found" (exit 1)**
- **Cause**: Framework not cloned to `.architecture/.architecture/`
- **Solution**: `git clone https://github.com/bettison-org/ai-software-architect .architecture/.architecture`

**"project-root must be an absolute path" (exit 1)**
- **Cause**: Relative path passed to script
- **Solution**: Use `"$(pwd)"` when invoking the script

**"Failed to copy framework files" (exit 2)**
- **Cause**: Insufficient file permissions
- **Solution**: `chmod -R u+rw .architecture/`

**"does not appear to be the template repository" (exit 3)**
- **Cause**: `.architecture/.git/config` doesn't contain `ai-software-architect`
- **Solution**: Manually verify the `.git` directory. If it's safe to remove, do so manually with `rm -rf "$(pwd)/.architecture/.git"`
- **Never**: Override safety checks without understanding why they failed

**"Installation incomplete" (exit 4)**
- **Cause**: Copy succeeded but some files are missing
- **Solution**: Check what's missing (listed in error), verify the cloned framework contains all expected files

### Verification Commands

Check installation completeness manually:

```bash
# Required directories
test -d .architecture/decisions/adrs && echo "OK ADRs" || echo "MISSING ADRs"
test -d .architecture/reviews && echo "OK reviews" || echo "MISSING reviews"
test -d .architecture/templates && echo "OK templates" || echo "MISSING templates"

# Required files
test -f .architecture/members.yml && echo "OK members" || echo "MISSING members"
test -f .architecture/principles.md && echo "OK principles" || echo "MISSING principles"
test -f .architecture/config.yml && echo "OK config" || echo "MISSING config"

# Should NOT exist after cleanup
test -d .architecture/.git && echo "WARNING: template .git still present"
test -d .architecture/.architecture && echo "WARNING: clone directory still present"
```

---

## Recovery

**If installation fails mid-process**:
1. Remove partial installation: `rm -rf .architecture/` (if nothing important there yet)
2. Re-clone framework: `git clone https://github.com/bettison-org/ai-software-architect .architecture/.architecture`
3. Re-run the installation script

**If you accidentally removed the wrong .git**:
- If it was your project's `.git`: restore from backup immediately
- The script's safeguards (template repo URL check, path pattern check) are specifically designed to prevent this
- This is why the safeguards exist and must not be bypassed

---

## Post-Installation

After the script completes successfully:

1. **Customize** — The skill handles team members, principles, and CLAUDE.md
2. **Verify setup**: Run `"What's our architecture status?"`
3. **Review customizations**: Check `.architecture/members.yml` and `.architecture/principles.md`
4. **Create first ADR**: Document an early architectural decision

For customization procedures, see [customization-guide.md](./customization-guide.md).
