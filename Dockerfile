ARG DEBIAN_VERSION=bullseye
ARG DEBIAN_VERSION_NUMBER=11
ARG PROJECT=sink
ARG RUST_VERSION=1.71

# ====================================================================================================
# Base
FROM rust:${RUST_VERSION}-${DEBIAN_VERSION} AS build-base
ARG PROJECT

RUN <<EOT
#!/usr/bin/env bash
set -e

apt -q update
apt -qy --no-install-recommends install libzmq3-dev
rm -rf /var/lib/apt/lists/*
EOT

WORKDIR /app
COPY Cargo.toml Cargo.toml
COPY Cargo.lock Cargo.lock

RUN <<EOT
#!/usr/bin/env bash
set -eu

mkdir src
echo 'fn main() {}' > src/main.rs
cargo build --locked --release
rm src/main.rs target/release/deps/${PROJECT//-/_}*
EOT

COPY src src

RUN cargo build --locked --release && cp /app/target/release/${PROJECT} /app/${PROJECT}

# ====================================================================================================
# Release
FROM debian:${DEBIAN_VERSION}-slim AS release
ARG PROJECT

RUN <<EOT
#!/usr/bin/env bash
set -e

apt -q update
apt -qy --no-install-recommends install libzmq3-dev
rm -rf /var/lib/apt/lists/*
EOT

WORKDIR /app

COPY --from=build-base /app/${PROJECT} ./${PROJECT}

ENTRYPOINT ["./sink"]
