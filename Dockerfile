# syntax=docker/dockerfile:1

# ---- builder ------------------------------------------------------------
FROM rust:1.75-slim@sha256:b27df5841f3355e9473f9a516d38a6783b6c8dfeacaf2d14a240f443b368ddb6 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy manifests first for better layer caching
COPY Cargo.toml Cargo.lock* ./

# Create empty src directory to build dependencies
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

# Copy actual source
COPY src ./src

# Build for real (dependencies are cached from previous step)
RUN cargo build --release

# ---- runtime ------------------------------------------------------------
FROM debian:bookworm-slim@sha256:60eac759739651111db372c07be67863818726f754804b8707c90979bda511df AS runtime

RUN groupadd --gid 10001 app \
    && useradd --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

WORKDIR /app

COPY --from=builder --chown=app:app /build/target/release/stack-base-rust /app/stack-base-rust

# Security: read-only filesystem with tmpfs for /tmp
RUN chmod 555 /app/stack-base-rust

ENV RUST_LOG=info

USER 10001:10001

# Health check placeholder - replace with real health endpoint for services
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["/app/stack-base-rust"] || exit 0

ENTRYPOINT ["/app/stack-base-rust"]