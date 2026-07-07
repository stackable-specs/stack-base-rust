# ADR-005: Adopt Cargo-based Dependency Management Strategy

## Status

Accepted

## Context and Problem Statement

Rust projects have specific dependency management requirements that differ from other ecosystems. We need a strategy that ensures supply chain security, prevents dependency drift, and follows `docs/specs/security/dependency-management.md` while being idiomatic to Rust's Cargo tooling.

## Decision Drivers

- **Supply chain security:** Dependencies must be audited and verified
- **Reproducibility:** `Cargo.lock` ensures identical dependency resolution
- **Vulnerability detection:** Known CVEs must be caught before merge
- **Spec compliance:** Follow `docs/specs/security/dependency-management.md`
- **Rust idioms:** Use Cargo-native tooling (cargo-audit, cargo-deny, cargo-machete)

## Considered Options

### Option A: Cargo native + cargo-audit + cargo-deny

Use Cargo's built-in dependency management augmented with:
- `Cargo.lock` committed for applications (rust.md rule 3)
- `cargo-audit` for vulnerability scanning (rust.md rule 38)
- `cargo-deny` for license compliance and bans (rust.md rule 39)
- `cargo-machete` for unused dependency detection (rust.md rule 36)
- `cargo outdated` for dependency freshness (rust.md rule 35)

### Option B: Vendored dependencies

Vendor all dependencies into the repository:
- Complete offline builds
- Large repository size
- Manual updates required
- Doesn't align with Rust ecosystem norms

### Option C: No additional tooling

Use Cargo without security scanning:
- Simpler setup
- No vulnerability detection
- No license compliance enforcement
- Security risk

## Decision Outcome

Chosen option: **Option A: Cargo native + cargo-audit + cargo-deny**

### Rationale

1. **Ecosystem alignment:** Cargo is the standard Rust package manager
2. **Security:** cargo-audit checks against RustSec advisories
3. **Compliance:** cargo-deny enforces license and source policies
4. **Health:** cargo-machete and cargo-outdated keep dependencies clean

## Decision Details

### Cargo.toml Policies

Following `docs/specs/language/rust.md` rules 34-39:

```toml
[package]
name = "stack-base-rust"
version = "0.1.0"
edition = "2021"
rust-version = "1.75"  # MSRV

[dependencies]
# Always pin explicit versions, no wildcards
# Example: serde = "1.0.210", NOT serde = "*"

[dev-dependencies]
# Development-only dependencies
```

### Dependency Versioning

From rust.md rule 34:
- **Always pin versions:** Use explicit version numbers in `Cargo.toml`
- **No wildcards:** Avoid `*` or empty version requirements
- **Use `cargo add`:** `cargo add <crate>` pins versions correctly

### Cargo.lock

From rust.md rule 3:
- **Applications:** Commit `Cargo.lock` to version control
- **Libraries:** Exclude from version control (add to `.gitignore`)

This project is an application template, so `Cargo.lock` is committed.

### Security Scanning

| Tool | Purpose | Command |
|------|---------|---------|
| cargo-audit | RustSec vulnerability check | `cargo audit` |
| cargo-deny | License + source compliance | `cargo deny check` |
| cargo-machete | Unused dependencies | `cargo machete` |
| cargo-outdated | Dependency freshness | `cargo outdated` |
| cargo tree | Dependency graph | `cargo tree --duplicates` |

### CI Integration

```yaml
# Security stage in CI
- name: Security audit
  run: cargo audit

- name: License and ban check
  run: cargo deny check

- name: Check for unused dependencies
  run: cargo machete

- name: Check for duplicate versions
  run: cargo tree --duplicates
```

### cargo-deny Configuration

Create `deny.toml` (future):

```toml
[licenses]
unlicensed = "deny"
allow = ["MIT", "Apache-2.0"]

[sources]
unknown-registry = "deny"
unknown-git = "deny"

[advisories]
unmaintained = "warn"
```

## Consequences

### Positive

- **Security:** Vulnerabilities caught before merge
- **Compliance:** License and source policies enforced
- **Health:** Dependencies stay clean and up-to-date
- **Reproducibility:** Cargo.lock ensures identical builds

### Negative

- **Setup cost:** Must install cargo-audit, cargo-deny, cargo-machete
- **CI time:** Security scanning adds ~30-60 seconds to CI
- **Maintenance:** deny.toml configuration may need updates

### Neutral

- **Tool dependency:** Requires additional Cargo subcommands
- **Policy decisions:** License allow-list must be maintained

## References

- `docs/specs/security/dependency-management.md` — Dependency management spec
- `docs/specs/language/rust.md` — Rust dependency rules (34-39)
- [cargo-audit](https://github.com/rustsec/rustsec-cargo-audit) — Vulnerability scanner
- [cargo-deny](https://github.com/EmbarkStudios/cargo-deny) — License and source linter
- [cargo-machete](https://github.com/bnjbvr/cargo-machete) — Unused dependency finder