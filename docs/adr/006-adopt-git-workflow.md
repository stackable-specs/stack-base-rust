# ADR-006: Adopt Git Workflow with Branch Protection

## Status

Accepted

## Context and Problem Statement

This project needs a Git workflow that supports collaborative development, enables code review, and follows the conventions from `docs/specs/practices/git.md` and `docs/specs/practices/conventional-commits.md`.

## Decision Drivers

- **Collaboration:** Multiple contributors must work without conflicts
- **Code review:** Changes must be reviewed before merge
- **History clarity:** Commit history must be readable and traceable
- **Spec compliance:** Follow `docs/specs/practices/git.md` branching conventions
- **Automation:** Conventional commits enable changelog generation

## Considered Options

### Option A: Feature Branch Workflow with Conventional Commits

Use feature branches with conventional commit messages:
- `main` (or `master`) is protected and always deployable
- Feature branches: `feat/`, `fix/`, `refactor/`, `docs/`, `chore/`
- Pull requests require review before merge
- Conventional commit format: `type(scope): description`
- Squash merge to keep history clean

### Option B: Trunk-Based Development

All commits go directly to main:
- Faster iteration
- Requires comprehensive CI
- Less formal review process

### Option C: Git Flow

Use develop, feature, release, hotfix branches:
- Well-documented workflow
- More complex branching structure
- Suited for release-based deployments

## Decision Outcome

Chosen option: **Option A: Feature Branch Workflow with Conventional Commits**

### Rationale

1. **Spec alignment:** Matches `docs/specs/practices/git.md` recommendations
2. **Code review:** Pull requests enable thorough review
3. **History clarity:** Conventional commits + squash merge = clean history
4. **Automation:** Conventional commits enable automated changelogs

## Decision Details

### Branch Naming Convention

From `docs/specs/practices/git.md`:

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feat/<description>` | `feat/add-health-endpoint` |
| Fix | `fix/<description>` | `fix/memory-leak` |
| Refactor | `refactor/<description>` | `refactor/auth-module` |
| Docs | `docs/<description>` | `docs/update-readme` |
| Chore | `chore/<description>` | `chore/update-dependencies` |

### Commit Message Format

From `docs/specs/practices/conventional-commits.md`:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
- `feat(docker): add health check endpoint`
- `fix(cargo): resolve dependency conflict`
- `docs(adr): add ADR-001 for Rust edition`

### Branch Protection Rules

For `main`/`master`:

1. Require pull request before merging
2. Require at least 1 approval
3. Require status checks to pass:
   - `cargo fmt --check`
   - `cargo clippy -- -D warnings`
   - `cargo test`
4. Require branches to be up to date before merging
5. Require signed commits (optional)

### Merge Strategy

- **Squash and merge:** Combines all commits into one
- **Preserves:** One commit per feature/fix in main history
- **Message:** Uses PR title (must follow conventional commits)

## Consequences

### Positive

- **Clean history:** Main branch has one commit per feature
- **Code review:** All changes reviewed before merge
- **Automation:** Conventional commits enable tooling
- **Collaboration:** Multiple contributors can work simultaneously

### Negative

- **Process overhead:** Pull requests required for all changes
- **Review latency:** Changes wait for reviewer availability

### Neutral

- **Branch hygiene:** Contributors must follow naming conventions
- **Commit discipline:** Conventional commits require training

## References

- `docs/specs/practices/git.md` — Git workflow spec
- `docs/specs/practices/conventional-commits.md` — Commit message format
- [Conventional Commits](https://www.conventionalcommits.org/)