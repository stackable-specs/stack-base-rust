//! Stack Base Rust
//!
//! A Rust base project template following the stackable-specs methodology.

/// Main entry point
fn main() {
    println!("Hello from stack-base-rust!");
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_greeting() {
        // Test that the greeting function would produce expected output
        // This is a placeholder test - replace with actual tests as the project grows
        let expected = "Hello from stack-base-rust!";
        assert!(!expected.is_empty());
    }
}
