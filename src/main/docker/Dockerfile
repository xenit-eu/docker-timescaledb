# Step 1. build promscale_extension 
# based on https://github.com/timescale/promscale_extension/blob/master/Dockerfile

ARG BASEIMAGE

FROM $BASEIMAGE as builder

ARG PG_MAJOR_VERSION
ARG RUST_VERSION
ARG PROMSCALE_EXT_VERSION

SHELL ["/bin/bash", "-c"]

RUN set -ex \
    && apt-get update \
    && apt-get -y install \
      build-essential \
      coreutils \
      llvm \
      git \
      llvm-dev \
      bison \
      dpkg-dev dpkg \
      flex \
      gcc \
      libc-dev \
      libedit-dev \
      libxml2-dev \
      libxslt-dev \
      clang \
      g++ \
      make \
      libssl-dev \
      wget \
      postgresql-server-dev-$PG_MAJOR_VERSION \
      openssl \
      pkg-config

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    # prevents some issues with openssl
    RUSTFLAGS="-C target-feature=-crt-static" \
    PGEXTWLIST_VERSION=v1.11

RUN set -eux; \
    rustArch='x86_64-unknown-linux-gnu'; \

    url="https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init"; \
    # sha256 file is using below path \
    mkdir -p target/${rustArch}/release/; \
    wget "$url" -x -O target/${rustArch}/release/rustup-init; \
    wget "${url}.sha256" -O target/${rustArch}/release/rustup-init.sha256; \
    sha256sum -c target/${rustArch}/release/rustup-init.sha256; \
    chmod +x target/${rustArch}/release/rustup-init; \
    target/${rustArch}/release/rustup-init -y --no-modify-path --profile minimal  --component rustfmt --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm -rf target; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    cat /usr/local/cargo/env; \
    rustup --version; \
    /usr/local/cargo/bin/cargo --version; \
    /usr/local/cargo/bin/rustc --version;

RUN set -ex \
    && git clone  --branch $PGEXTWLIST_VERSION --depth 1 \
         https://github.com/dimitri/pgextwlist.git /pgextwlist \
    && cd /pgextwlist \
    && make \
    && make install \
    && mkdir `pg_config --pkglibdir`/plugins \
    && cp /pgextwlist/pgextwlist.so `pg_config --pkglibdir`/plugins \
    && rm -rf /pgextwlist

RUN set -ex \
    && cargo install --git https://github.com/JLockerman/pgx.git --branch timescale cargo-pgx \
    && cargo pgx init --pg$PG_MAJOR_VERSION /usr/bin/pg_config \
    && git clone  --branch $PROMSCALE_EXT_VERSION --depth 1 https://github.com/timescale/promscale_extension.git /build/promscale \
    && make -C /build/promscale rust \
    && make -C /build/promscale install

# Step2. Build TimescaleDB image

FROM $BASEIMAGE

# copy promscale_extension
COPY --from=builder /build/promscale /build/promscale

RUN set -ex \
    && apt-get update \
    && apt-get install -y \
      curl \
      gnupg \
      apt-transport-https \
      lsb-release \
      make \
      llvm \
    && echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/timescaledb.list \
    && curl -L https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add - \
    && apt-get update \
    && apt-get install -y timescaledb-2-2.4.1-postgresql-13 \
    && make -C /build/promscale install \
    && apt-get remove -y \
      g++ \
      curl \
      gnupg \
      apt-transport-https \
      lsb-release \
      make \
      llvm \
    && apt-get autoremove -y \
    && apt-get purge \
    && rm -rf /build

COPY root/ /


