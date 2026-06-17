ARG KOPIA_VERSION

FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS builder

ARG KOPIA_VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG GITHUB_REPOSITORY=kopia/kopia
ENV KOPIA_VERSION=${KOPIA_VERSION}

RUN apk add --no-cache git wget ca-certificates

WORKDIR /src

RUN set -eux; \
    if [ -n "$KOPIA_VERSION" ]; then \
      VER="$KOPIA_VERSION"; \
    else \
      VER="$(wget -qO- https://api.github.com/repos/kopia/kopia/releases/latest | awk -F\" '/"tag_name":/ {print $4; exit}')"; \
    fi; \
    echo "Building kopia version: $VER"; \
    wget -qO /tmp/kopia.tar.gz "https://github.com/kopia/kopia/archive/refs/tags/${VER}.tar.gz"; \
    tar -xzf /tmp/kopia.tar.gz --strip-components=1 -C /src; \
    echo "$VER" > /tmp/VERSION

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    set -eux; \
    VER="$(cat /tmp/VERSION)"; \
    VERSION_NO_PREFIX="${VER#v}"; \
    export CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}"; \
    case "${TARGETVARIANT}" in \
      v5) export GOARM=5 ;; \
      v6) export GOARM=6 ;; \
      v7) export GOARM=7 ;; \
    esac; \
    go build -trimpath \
      -ldflags "-s -w \
        -X github.com/kopia/kopia/repo.BuildVersion=${VERSION_NO_PREFIX} \
        -X github.com/kopia/kopia/repo.BuildInfo=from-source \
        -X github.com/kopia/kopia/repo.BuildGitHubRepo=${GITHUB_REPOSITORY}" \
      -o /out/kopia .

FROM alpine:latest AS runtime

ENV KOPIA_CONFIG_PATH=/app/config/repository.config \
    KOPIA_LOG_DIR=/app/logs \
    KOPIA_CACHE_DIRECTORY=/app/cache \
    KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=false \
    KOPIA_CHECK_FOR_UPDATES=false

RUN apk add --no-cache ca-certificates fuse3 tzdata

COPY --from=builder /out/kopia /usr/local/bin/kopia

RUN chmod +x /usr/local/bin/kopia

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/kopia"]
