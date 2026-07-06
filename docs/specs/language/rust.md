---
id: rust
layer: language
extends: []
---

# Rust

## Purpose

Rust guarantees memory safety without garbage collection through its ownership system, but those guarantees only hold when the code respects the borrowing rules the compiler enforces and when `unsafe` blocks are used deliberately with documented invariants. Beyond safety, Rust's toolchain (`cargo`, `rustfmt`, `clippy`, `rust-analyzer`) provides opinionated defaults that eliminate formatting debates and catch real defects before CI. This spec pins the language version, edition, formatting, linting, idiomatic patterns, and the boundary between safe and `unsafe` code so every contributor can rely on consistent semantics, reproducible builds, and a compiler that fails fast — not silently.

## References

### Language & Documentation

- **external** `https://www.rust-lang.org/` — Rust language home
- **external** `https://doc.rust-lang.org/book/` — The Rust Programming Language Book
- **external** `https://doc.rust-lang.org/nomicon/` — The Rustonomicon (unsafe Rust)
- **external** `https://doc.rust-lang.org/reference/` — The Rust Reference
- **external** `https://doc.rust-lang.org/cargo/` — Cargo Book
- **external** `https://rust-lang.github.io/api-guidelines/` — Rust API Guidelines

### Standard Tooling

- **external** `https://doc.rust-lang.org/rustfmt/` — rustfmt reference
- **external** `https://doc.rust-lang.org/clippy/` — Clippy linter
- **external** `https://rust-lang.github.io/rust-clippy/master/index.html` — Clippy lint list

### Testing Tools

- **external** `https://nexte.st/` — cargo-nextest (faster test runner)
- **external** `https://github.com/taiki-e/cargo-llvm-cov` — LLVM coverage
- **external** `https://github.com/xd009642/tarpaulin` — cargo-tarpaulin (coverage)
- **external** `https://github.com/proptest-rs/proptest` — proptest (property-based testing)
- **external** `https://github.com/BurntSushi/quickcheck` — quickcheck (property-based testing)
- **external** `https://rust-fuzz.github.io/book/` — cargo-fuzz (fuzz testing)
- **external** `https://github.com/tokio-rs/loom` — loom (concurrency testing)
- **external** `https://bheisler.github.io/criterion.rs/book/` — criterion (benchmarking)

### Quality Tools

- **external** `https://github.com/obi1kenobi/cargo-semver-checks` — API compatibility checks
- **external** `https://pre-commit.com/` — pre-commit framework

### Security Tools

- **external** `https://github.com/rustsec/rustsec-cargo-audit` — cargo-audit (vulnerability advisories)
- **external** `https://github.com/EmbarkStudios/cargo-deny` — cargo-deny (licenses, bans, audits)
- **external** `https://github.com/mozilla/cargo-vet` — cargo-vet (supply-chain review)
- **external** `https://github.com/rust-secure-code/cargo-auditable` — cargo-auditable (dependency embedding)
- **external** `https://github.com/rust-secure-code/cargo-geiger` — cargo-geiger (unsafe code detection)
- **external** `https://github.com/rust-lang/miri` — miri (undefined behavior detection)

## Rules

### Language & Edition

1. Declare the Rust edition in `Cargo.toml` (e.g., `edition = "2021"`); keep it within the two most recent stable editions.
2. Declare the MSRV in `Cargo.toml` when the crate is a library; run CI against the MSRV.
3. Commit `Cargo.lock` for binaries and applications; exclude it from version control for libraries.

### Formatting & Linting

4. Run `cargo fmt --check` in CI; do not merge PRs with unformatted code.
5. Run `cargo clippy --all-targets --all-features -- -D warnings` in CI.
6. Use `#![warn(rustdoc::broken_intra_doc_links)]` to catch broken doc links.

### Error Handling

7. Use `Result<T, E>` for operations that can fail; do not use `panic!` for expected failures.
8. Use `Option<T>` for values that may be absent; do not use sentinel values.
9. Handle errors explicitly or propagate with `?`; do not silence errors without comment.

### Unsafe Code

13. Document every `unsafe` block with a `// SAFETY:` comment.
14. Prefer safe abstractions; encapsulate `unsafe` in modules with safe public APIs.
15. Use `#![forbid(unsafe_code)]` for crates that must not contain unsafe.

### Testing

24. Place unit tests in same file using `#[cfg(test)] mod tests { ... }`.
27. Run `cargo nextest run --workspace --all-features` in CI.
28. Run `cargo test --doc` to verify documentation examples.

### Dependencies

34. Pin versions in `Cargo.toml` with explicit version numbers.
38. Run `cargo audit` in CI to check for vulnerabilities.
39. Run `cargo deny check` to enforce license compliance.