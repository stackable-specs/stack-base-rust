# ADR-001: Adopt Rust 2021 Edition with MSRV Policy

## Status

Accepted

## Context and Problem Statement

This project is a Rust base template intended to be AI-agent friendly with strong quality and correctness controls. We need to establish the language version, edition, and toolchain policies that ensure reproducibility, compatibility, and safety while following the stackable-specs methodology.

## Decision Drivers

- **Reproducibility:** Builds must produce consistent results across environments
- **Safety:** Rust's ownership system and borrow checker must be leveraged fully
- **Toolchain:** Opinionated defaults (cargo, rustfmt, clippy) eliminate formatting debates and catch defects early
- **Compatibility:** MSRV ensures the project works for a broad audience
- **Spec compliance:** Must follow all rules in `docs/specs/language/rust.md`

## Considered Options

### Option A: Rust 2021 Edition with explicit MSRV (1.75)

- Latest stable edition with modern features
- Explicit MSRV in Cargo.toml for compatibility
- rust-toolchain.toml pins exact toolchain version
- Supports all modern Rust idioms and patterns

### Option B: Rust 2018 Edition

- Older edition, broader compatibility
- Missing 2021 features (const generics improvements, disjoint capture in closures)
- Would need to upgrade eventually

### Option C: No explicit edition or MSRV

- Defaults to latest stable
- Unpredictable builds across environments
- No guarantee of compatibility

## Decision Outcome

Chosen option: **Option A: Rust 2021 Edition with explicit MSRV (1.75)**

### Rationale

1. **Edition 2021 is the current stable:** Within the two most recent stable editions as per rust.md rule 1
2. **MSRV ensures reproducibility:** CI runs against 1.75 to prevent accidental breaking changes
3. **Safety by default:** `#![forbid(unsafe_code)]` via lint enforcement (clippy -D warnings)
4. **Toolchain consistency:** `rust-toolchain.toml` pins the exact Rust version and components

## Decision Details

### Cargo.toml Configuration

```toml
[package]
edition = "2021"
rust-version = "1.75"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
panic = "abort"
strip = true
```

### rust-toolchain.toml

```toml
[toolchain]
channel = "1.75"
components = ["rustfmt", "clippy", "rust-src", "rust-analyzer"]
profile = "default"
```

### Quality Enforcement

Lints are enforced via command-line flags in CI:
- `cargo fmt --check` — formatting verification (rust.md rule 4)
- `cargo clippy -- -D warnings` — all warnings are errors (rust.md rule 5)
- `RUSTDOCFLAGS="-D warnings" cargo doc --no-deps` — doc warnings are errors (rust.md rule 33)

### Unsafe Code Policy

This template forbids unsafe code by default:
- Lint enforcement via `cargo clippy -- -D warnings` catches unsafe patterns
- If unsafe is needed, it must be documented with `// SAFETY:` comments (rust.md rule 13)
- `cargo geiger` should be run in CI to track unsafe usage (future)

## Consequences

### Positive

- **Reproducibility:** Same Rust version produces consistent builds
- **Safety:** Compiler enforces memory safety; unsafe code requires explicit opt-in
- **Quality:** Formatting and linting enforced before merge
- **Compatibility:** MSRV 1.75 supports a broad range of environments

### Negative

- **Version management:** MSRV must be updated periodically
- **Feature lag:** May miss features from newer Rust versions until MSRV is bumped

### Neutral

- **Toolchain dependency:** Contributors must have Rust 1.75+ installed
- **CI configuration:** Must run against MSRV to catch compatibility regressions

## References

- `docs/specs/language/rust.md` — Rust language spec
- [Rust Edition Guide](https://doc.rust-lang.org/edition-guide/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)