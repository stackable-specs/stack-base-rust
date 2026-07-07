# ADR-003: Adopt Pre-commit Hooks for Quality Gates

## Status

Accepted

## Context and Problem Statement

This project needs automated quality gates that run before code is committed, ensuring that only well-formed, properly linted code enters the repository. The gates must support Rust-specific tooling and follow the stackable-specs methodology.

## Decision Drivers

- **Early feedback:** Catch issues before they reach CI
- **Consistency:** All contributors follow the same quality rules
- **Spec compliance:** Follow `docs/specs/practices/conventional-commits.md`
- **Toolchain integration:** Rust tooling (cargo fmt, cargo clippy) must be enforced
- **AI-agent friendliness:** Hooks should be explicit and documented

## Considered Options

### Option A: Pre-commit Framework with Local Hooks

Use the pre-commit framework with local hooks for Rust tooling:
- cargo fmt --check (formatting)
- cargo clippy -- -D warnings (linting)
- cargo check (compilation)
- hadolint (Dockerfile linting)
- gitleaks (secret scanning)
- conventional-pre-commit (commit message format)

### Option B: Cargo-only Hooks via cargo-husky

Use cargo-husky for Rust-specific git hooks:
- Native Rust integration
- Simpler setup for Rust projects
- Less flexible for non-Rust hooks

### Option C: Husky (Node.js)

Use Husky with npm package manager:
- Popular in JavaScript ecosystem
- Requires Node.js installation
- Overkill for a pure Rust project

### Option D: Manual CI-only Checks

Run all checks in CI only:
- No local feedback
- Slower feedback loop
- Higher CI costs

## Decision Outcome

Chosen option: **Option A: Pre-commit Framework with Local Hooks**

### Rationale

1. **Rust-native:** Local hooks call cargo directly without additional dependencies
2. **Comprehensive:** Supports Docker, secrets, and commit messages in addition to Rust
3. **Industry standard:** pre-commit.com is widely adopted and well-documented
4. **Flexible:** Easy to add new hooks as project grows

## Decision Details

### .pre-commit-config.yaml

```yaml
repos:
  # Rust formatting
  - repo: local
    hooks:
      - id: cargo-fmt
        name: Cargo fmt
        entry: bash -c 'cargo fmt --check'
        language: system
        files: \.rs$
        pass_filenames: false

  # Rust linting with Clippy
  - repo: local
    hooks:
      - id: cargo-clippy
        name: Cargo clippy
        entry: bash -c 'cargo clippy --all-targets --all-features -- -D warnings'
        language: system
        files: \.rs$
        pass_filenames: false

  # Cargo check
  - repo: local
    hooks:
      - id: cargo-check
        name: Cargo check
        entry: bash -c 'cargo check --workspace --all-targets --all-features'
        language: system
        files: (Cargo\.toml|Cargo\.lock|\.rs)$
        pass_filenames: false

  # Rust tests (pre-push stage)
  - repo: local
    hooks:
      - id: cargo-test
        name: Cargo test
        entry: bash -c 'cargo test --workspace'
        language: system
        files: \.rs$
        pass_filenames: false
        stages: [pre-push]

  # Dockerfile linting with Hadolint
  - repo: https://github.com/hadolint/hadolint
    rev: v2.12.0
    hooks:
      - id: hadolint-docker

  # Docker Compose validation
  - repo: local
    hooks:
      - id: compose-validate
        name: Validate Docker Compose
        entry: bash -c 'docker compose config --quiet'
        language: system
        files: ^compose.*\.ya?ml$
        pass_filenames: false

  # Trivy misconfiguration scanning
  - repo: local
    hooks:
      - id: trivy-config
        name: Trivy IaC Scan
        entry: bash -c 'trivy config Dockerfile compose.yaml compose.override.yaml 2>/dev/null || true'
        language: system
        files: ^(Dockerfile|compose.*\.ya?ml)$
        pass_filenames: false

  # Secret scanning with gitleaks
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.1
    hooks:
      - id: gitleaks

  # Conventional commits
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.2.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
```

### Hook Stages

| Stage | Hooks | Purpose |
|-------|-------|---------|
| pre-commit | cargo fmt, cargo clippy, cargo check, hadolint, gitleaks | Block bad commits |
| commit-msg | conventional-pre-commit | Enforce commit message format |
| pre-push | cargo test | Run tests before push |

## Consequences

### Positive

- **Early feedback:** Issues caught before commit reaches repository
- **Consistency:** All contributors follow identical quality rules
- **CI efficiency:** Fewer CI failures due to caught issues locally
- **Security:** Secrets scanned before commit (gitleaks)

### Negative

- **Setup requirement:** Contributors must install pre-commit (`pip install pre-commit` or `brew install pre-commit`)
- **Commit latency:** Hooks add ~5-30 seconds to each commit
- **Rust installation:** Contributors need Rust toolchain for local hooks

### Neutral

- **Tool dependency:** Requires pre-commit framework and Rust toolchain
- **Configuration maintenance:** Hooks must be kept in sync with project structure

## References

- `docs/specs/practices/conventional-commits.md` — Commit message format
- [pre-commit.com](https://pre-commit.com/) — Pre-commit framework
- [Hadolint](https://github.com/hadolint/hadolint) — Dockerfile linter
- [Gitleaks](https://github.com/gitleaks/gitleaks) — Secret scanner