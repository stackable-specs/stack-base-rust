# ADR-002: Adopt Docker and Docker Compose for Containerization

## Status

Accepted

## Context and Problem Statement

This project is a Rust base template intended to be AI-agent friendly with strong quality and correctness controls. To ensure reproducibility, portability, and consistency across development, CI, and production environments, we need a containerization strategy that:

1. Produces minimal, secure container images
2. Enables local development with fast iteration
3. Supports single-host deployments (Compose) with a path to orchestration (Kubernetes)
4. Enforces quality gates on images (vulnerability scanning, SBOM, signing)
5. Follows the stackable-specs methodology for spec-driven development

## Decision Drivers

- **Reproducibility:** Builds must produce identical images from the same source code
- **Security:** Images must run as non-root, have minimal attack surface, and be scannable
- **Spec compliance:** Must follow all rules in `docs/specs/delivery/docker.md` and `docker-compose.md`
- **Developer experience:** Must support fast iteration with local development
- **AI-agent friendliness:** Configuration must be explicit, documented, and verifiable
- **Supply chain security:** Images must be pinned by digest, signed, and accompanied by SBOMs

## Considered Options

### Option A: Docker + Docker Compose (with spec compliance)

Use Docker with multi-stage Dockerfiles and Docker Compose for orchestration, following all stackable-specs rules:
- Multi-stage builds with minimal runtime images
- Base images pinned by SHA256 digest
- Non-root user execution
- Read-only root filesystem with tmpfs
- Bounded logging and resource limits
- Development overrides via compose.override.yaml

### Option B: Podman + Podman Compose

Use Podman as a daemonless alternative with Podman Compose:
- Rootless by default
- Compatible with Docker CLI
- Podman Compose as drop-in replacement

### Option C: Kaniko for CI-only builds

Use Kaniko for building images in CI without Docker daemon:
- No privileged container required
- Better for CI/CD security
- No local development story

### Option D: No containerization (bare metal)

Skip containerization and rely on cargo install:
- Simpler initial setup
- No container orchestration knowledge required
- No reproducibility guarantees across environments

## Decision Outcome

Chosen option: **Option A: Docker + Docker Compose (with spec compliance)**

We will use Docker with multi-stage Dockerfiles and Docker Compose, following all rules from `docs/specs/delivery/docker.md` and `docs/specs/delivery/docker-compose.md`.

### Rationale

1. **Spec alignment:** The docker.md and docker-compose.md specs provide comprehensive rules
2. **Ecosystem maturity:** Docker and Compose have the largest ecosystem and tooling support
3. **AI-agent friendliness:** Well-documented and widely understood by AI coding agents
4. **Path to production:** Compose for single-host, Kubernetes as an upgrade target
5. **Supply chain security:** Mature tools for signing (cosign), scanning (Trivy), and SBOM generation

## Decision Details

### Dockerfile Implementation

- Multi-stage build with `builder` and `runtime` stages
- Base image: `rust:1.75-slim` pinned by SHA256 digest with tag comment
- Non-root user: `10001:10001`
- Healthcheck placeholder for long-running services
- BuildKit cache mounts for faster builds
- Stripped release binary for minimal size

### Docker Compose Implementation

- Named `compose.yaml` (not `docker-compose.yml`)
- No top-level `version:` key (Compose spec unversioned)
- Explicit project `name: stack-base-rust`
- Resource limits via `deploy.resources.limits`
- Read-only root filesystem with `tmpfs` for `/tmp`
- Bounded logging (json-file with max-size/max-file)
- Non-root `user:` directive
- Development overrides in `compose.override.yaml`
- Environment interpolation via `${VAR}` from `.env`
- `.env.example` documents all variables

### SHA Pinning Strategy

We will use **gh-pin** (GitHub CLI extension) for automated SHA pinning:

```bash
# Install gh-pin
gh extension install grantbirki/gh-pin

# Pin all Docker images in Dockerfile
gh pin Dockerfile

# Pin images in compose.yaml
gh pin compose.yaml
```

### Linting Strategy

- **Hadolint:** Dockerfile linting (DL3001, DL3002, DL3020, DL3025)
- **Trivy:** Misconfiguration scanning for Dockerfile and Compose files
- **Built-in Compose validation:** `docker compose config --quiet`

## Consequences

### Positive

- **Reproducibility:** Images built from same source produce identical outputs
- **Security:** Non-root execution, read-only filesystem, minimal attack surface
- **Spec compliance:** All rules from docker.md and docker-compose.md are followed
- **Developer experience:** `compose.override.yaml` enables fast iteration during development
- **Supply chain security:** SHA pinning prevents mutable tag attacks

### Negative

- **Complexity:** Multi-stage Dockerfiles require more initial setup
- **Learning curve:** Contributors must understand Docker and Compose concepts
- **Build time:** Multi-stage builds take longer than single-stage (mitigated by BuildKit cache)
- **Maintenance:** SHA digests must be updated when base images change

## References

- `docs/specs/delivery/docker.md` — Docker image spec
- `docs/specs/delivery/docker-compose.md` — Compose file spec
- [gh-pin GitHub repository](https://github.com/GrantBirki/gh-pin)