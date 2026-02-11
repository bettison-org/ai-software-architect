---
name: setup-architect
description: Sets up and installs the AI Software Architect framework in a NEW project for the FIRST time. Use when the user requests "Setup .architecture", "Setup ai-software-architect", "Initialize architecture framework", "Install software architect", or similar setup/installation phrases. Do NOT use for checking status (use architecture-status), creating documents (use create-adr or reviews), or when framework is already set up.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash
---

# Setup AI Software Architect Framework

Sets up and customizes the AI Software Architect framework for a project.

## Overview

This skill performs a complete framework installation:
1. Analyzes project (languages, frameworks, structure, patterns)
2. Installs framework files via deterministic script
3. Customizes team members and principles for detected tech stack
4. Updates CLAUDE.md integration
5. Performs initial system analysis
6. Reports customizations and findings

**Customization guide**: [references/customization-guide.md](references/customization-guide.md)
**Troubleshooting**: [references/installation-procedures.md](references/installation-procedures.md)

## High-Level Workflow

### 1. Analyze Project

Identify project characteristics before installation:
- **Languages**: JavaScript/TypeScript, Python, Ruby, Java, Go, Rust
- **Frameworks**: React, Vue, Django, Rails, Spring, etc.
- **Infrastructure**: Testing setup, CI/CD, package managers
- **Structure**: Directory layout, architectural patterns

Use `Glob` and `Grep` to detect technologies, `Read` to examine configs.

### 2. Install Framework

**If `.architecture/.architecture/` does not exist**, guide the user to clone first:
```
git clone https://github.com/bettison-org/ai-software-architect .architecture/.architecture
```

**Once cloned**, run the installation script. The script handles all file operations deterministically: prerequisite checks, copying framework files, creating directories, initializing config, cleaning up framework docs, and safely removing the template `.git/` directory.

```bash
bash "<skill-base-dir>/scripts/install-framework.sh" "$(pwd)"
```

Where `<skill-base-dir>` is this skill's base directory shown at the top of the skill prompt.

The script outputs structured status tokens. If it fails, check stderr for the specific error. See [references/installation-procedures.md § Troubleshooting](references/installation-procedures.md#troubleshooting) for recovery steps.

### 3. Customize Architecture Team

Add technology-specific members to `.architecture/members.yml`:
- **JavaScript/TypeScript**: JavaScript Expert, framework specialists (React/Vue/Angular)
- **Python**: Python Expert, framework specialists (Django/Flask/FastAPI)
- **Ruby**: Ruby Expert, Rails Architect
- **Java**: Java Expert, Spring Boot Specialist
- **Go**: Go Expert, Microservices Architect
- **Rust**: Rust Expert, Systems Programmer

Use template from [assets/member-template.yml](assets/member-template.yml).

**Keep core members**: Systems Architect, Domain Expert, Security, Performance, Maintainability, AI Engineer, Pragmatic Enforcer.

**Customization details**: [references/customization-guide.md § Customize Team Members](references/customization-guide.md#customize-architecture-team-members)

### 4. Customize Architectural Principles

Add framework-specific principles to `.architecture/principles.md`:
- **React**: Component composition, hooks, unidirectional data flow
- **Rails**: Convention over configuration, DRY, RESTful design
- **Django**: Explicit over implicit, reusable apps, use built-ins

**Principle examples**: [references/customization-guide.md § Customize Principles](references/customization-guide.md#customize-architectural-principles)

### 5. Update CLAUDE.md Integration

If `CLAUDE.md` exists in project root, append framework usage section:
- Available commands
- Where to find documentation
- How to invoke skills

**Template**: [references/customization-guide.md § Update CLAUDE.md](references/customization-guide.md#update-claudemd-integration)

### 6. Create Initial System Analysis

Generate comprehensive initial analysis document:
- Each member analyzes system from their perspective
- System overview (stack, structure, patterns)
- Strengths identified
- Concerns raised (with impact levels)
- Recommendations prioritized (Critical/Important/Nice-to-Have)
- Collaborative synthesis of findings

Save to `.architecture/reviews/initial-system-analysis.md`.

**Template**: [assets/initial-analysis-template.md](assets/initial-analysis-template.md)

### 7. Report to User

Provide setup summary:

```
AI Software Architect Framework Setup Complete

Customizations:
- Added [N] technology specialists: [list]
- Customized principles for: [frameworks]
- Configuration: Pragmatic mode [enabled/disabled]

Initial Analysis Highlights:
- Overall assessment: [assessment]
- Top strength: [strength]
- Top concern: [concern]
- Critical recommendation: [recommendation]

Location: .architecture/reviews/initial-system-analysis.md

Next Steps:
- Review initial analysis findings
- "List architecture members" to see customized team
- "Create ADR for [first decision]" to start documenting
- "What's our architecture status?" to verify setup
```

## Error Handling

**Framework not cloned**:
```
The framework must be cloned first. Please run:

git clone https://github.com/bettison-org/ai-software-architect .architecture/.architecture

Then run setup again.
```

**Installation script fails**:
```
The installation script exited with an error. Check the error message above.

Common causes:
- Exit 1: Framework not cloned or bad project path
- Exit 2: File copy failed (check permissions)
- Exit 3: Safety check failed during .git cleanup (manual verification needed)
- Exit 4: Installation incomplete (missing files after copy)

For recovery: see references/installation-procedures.md § Troubleshooting
```

**Already set up**:
```
Framework appears to be already set up.

To verify: "What's our architecture status?"
To reconfigure: Manually edit .architecture/members.yml and .architecture/principles.md
```

**Unclear project structure**:
```
Could not clearly identify project type. Please describe:
- Primary programming language(s)
- Framework(s) used
- Project purpose

I'll customize the framework accordingly.
```

## Related Skills

**After Setup**:
- `list-members` - View customized team
- `architecture-status` - Verify setup completion
- `create-adr` - Document first decision

**Initial Work**:
- Review `initial-system-analysis.md` findings
- `specialist-review` - Deep-dive on specific concerns
- `create-adr` - Document existing key decisions

**Workflow Example**:
Setup → Review initial analysis → Create ADRs → Status check → Regular reviews

## Notes

- Customize based on **actual** project, not every possible option
- Be specific about **why** each customization was made
- Initial analysis should be thorough but focused on actionable findings
- The installation script handles all file operations — do not manually run cp/mkdir/rm commands

## Documentation

- **Troubleshooting & recovery**: [references/installation-procedures.md](references/installation-procedures.md)
- **Customization guide**: [references/customization-guide.md](references/customization-guide.md)
- **Initial analysis template**: [assets/initial-analysis-template.md](assets/initial-analysis-template.md)
- **Member template**: [assets/member-template.yml](assets/member-template.yml)
- **Common patterns**: [../_patterns.md](../_patterns.md)
