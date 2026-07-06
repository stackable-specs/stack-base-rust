# stack-base-rust

A Rust base project template following the `stackable-specs` methodology.

## Included Specs

| Spec | Layer | Why it's essential |
| ---- | ----- | ------------------ |
| `language/rust.md` | language | Rust language conventions, ownership rules, unsafe boundaries |
| `practices/madr.md` | practices | ADR format and lifecycle |
| `practices/bdr.md` | practices | Behavior record format and lifecycle |
| `practices/conventional-commits.md` | practices | Commit message contract |
| `practices/tdd.md` | practices | Red-green-refactor discipline |
| `practices/git.md` | practices | Branch and merge workflow |
| `quality/unit-testing.md` | quality | Unit-test scope and naming rules |
| `security/dependency-management.md` | security | Dependency policy |
| `delivery/docker.md` | delivery | Container image conventions |
| `delivery/docker-compose.md` | delivery | Compose file conventions |
| `delivery/github-actions.md` | delivery | CI/CD pipeline conventions |

## Repository layout

```
.
├── .github/
│   └── workflows/          # CI/CD pipelines
├── docs/
│   ├── adr/                # Architectural Decision Records (MADR format)
│   ├── bdr/                # Behavior Decision Records
│   └── specs/              # Specs from stackable-specs
│       ├── delivery/
│       ├── language/
│       ├── practices/
│       ├── quality/
│       └── security/
├── src/                    # Application source code
├── tests/                  # Integration tests
├── verify/                 # Smoke / post-deploy verification scripts
├── workspace/              # AI agent working directory
├── .dockerignore
├── .env.example
├── .gitignore
├── .hadolint.yaml          # Dockerfile linting config
├── .pre-commit-config.yaml # Pre-commit hooks
├── .rust-toolchain.toml    # Pinned Rust toolchain
├── Cargo.toml              # Project metadata and dependencies
├── Cargo.lock              # Locked dependencies
├── Dockerfile
├── compose.yaml
├── compose.override.yaml
└── README.md
```

## Getting started

This project was initialized with `cargo new` and follows the stackable-specs layered specification model.

1. Install Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
2. Build: `cargo build`
3. Run: `cargo run`
4. Test: `cargo test`
5. Lint: `cargo fmt --check && cargo clippy -- -D warnings`

## Docker

1. Build: `docker build -t stack-base-rust .`
2. Run: `docker compose up`

## Baseline checks

```bash
# Quality
cargo fmt --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo check --workspace --all-targets --all-features

# Testing
cargo test --workspace
cargo test --doc

# Security
cargo audit
cargo deny check

# Health
cargo machete
cargo tree --duplicates
```

## References

- [stackable-specs/specs](https://github.com/stackable-specs/specs) — Source of the specification files
- [The Rust Programming Language](https://doc.rust-lang.org/book/) — Official Rust book
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) — Idiomatic Rust patterns