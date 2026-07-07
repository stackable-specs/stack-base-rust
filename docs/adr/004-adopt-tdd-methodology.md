# ADR-004: Adopt Test-Driven Development Methodology

## Status

Accepted

## Context and Problem Statement

This project requires a rigorous testing methodology that ensures correctness and maintainability. Tests must be written before implementation, follow naming conventions, and provide comprehensive coverage as specified in `docs/specs/practices/tdd.md` and `docs/specs/quality/unit-testing.md`.

## Decision Drivers

- **Correctness:** Tests prove behavior works before implementation
- **Documentation:** Tests serve as executable documentation
- **Refactoring safety:** Tests allow confident code changes
- **Spec compliance:** Follow `docs/specs/practices/tdd.md` red-green-refactor discipline
- **Quality standard:** Meet coverage thresholds from `docs/specs/quality/unit-testing.md`

## Considered Options

### Option A: TDD with cargo test + cargo nextest

Follow TDD discipline using Rust's built-in test framework plus nextest:
- Write failing test first (red)
- Write minimal code to pass (green)
- Refactor while keeping tests green (refactor)
- Run tests with `cargo nextest run` for faster CI execution

### Option B: TDD with cargo test only

Use only built-in `cargo test`:
- Simpler setup
- Slower test execution
- No parallel test runner benefits

### Option C: No formal TDD, just testing

Write tests after implementation:
- No red-green-refactor discipline
- Tests may not cover edge cases
- Easier for contributors unfamiliar with TDD

## Decision Outcome

Chosen option: **Option A: TDD with cargo test + cargo nextest**

### Rationale

1. **Faster feedback:** nextest runs tests in parallel, reducing CI time
2. **Better diagnostics:** nextest provides clearer failure output
3. **Industry standard:** TDD is widely practiced and well-documented
4. **Spec alignment:** Follows tdd.md red-green-refactor discipline

## Decision Details

### Test Organization

Following `docs/specs/quality/unit-testing.md` and rust.md rules 24-29:

| Type | Location | Purpose |
|------|----------|---------|
| Unit tests | `#[cfg(test)] mod tests { ... }` in same file | Test individual functions/types |
| Integration tests | `tests/` directory | Test module interactions |
| Doc tests | `/// ``` ... ``` ` comments | Verify documentation examples |

### Test Naming Convention

From `docs/specs/quality/unit-testing.md`:

```rust
#[cfg(test)]
mod tests {
    // Pattern: test_<function>_<scenario>_<expected_result>
    #[test]
    fn test_parse_valid_input_returns_ok() { ... }

    #[test]
    fn test_parse_invalid_input_returns_error() { ... }
}
```

### TDD Workflow

1. **Red:** Write a failing test
   ```bash
   cargo test test_new_feature  # Fails: function doesn't exist
   ```

2. **Green:** Write minimal code to pass
   ```bash
   cargo test test_new_feature  # Passes
   ```

3. **Refactor:** Improve code while keeping tests green
   ```bash
   cargo test  # All tests pass
   cargo clippy -- -D warnings  # No lint warnings
   ```

### CI Integration

```yaml
# Test stage in CI
- name: Run tests
  run: cargo nextest run --workspace --all-features

- name: Run doc tests
  run: cargo test --doc
```

### Coverage

Future: Add `cargo llvm-cov` for coverage reporting (rust.md rule 29):
```bash
cargo llvm-cov nextest --workspace --all-features
```

Target: 80% coverage floor for new modules.

## Consequences

### Positive

- **Correctness:** Tests prove behavior works
- **Documentation:** Tests serve as executable specs
- **Refactoring safety:** Tests catch regressions
- **Fast CI:** nextest runs tests in parallel

### Negative

- **Learning curve:** Contributors must understand TDD
- **Initial slowdown:** Writing tests first takes more time initially
- **Maintenance:** Tests require maintenance alongside code

### Neutral

- **Tool dependency:** Requires cargo-nextest for optimal experience
- **Coverage tool:** Requires cargo-llvm-cov for coverage metrics

## References

- `docs/specs/practices/tdd.md` — TDD methodology
- `docs/specs/quality/unit-testing.md` — Unit testing conventions
- `docs/specs/language/rust.md` — Rust testing rules (24-29)
- [cargo-nextest](https://nexte.st/) — Faster test runner
- [cargo-llvm-cov](https://github.com/taiki-e/cargo-llvm-cov) — Coverage tool