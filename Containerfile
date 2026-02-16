FROM jenkins/inbound-agent:trixie-jdk25

# Take root rights
USER 0

# Install pre-built binaries for building/running maestro
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update \
    && apt-get --no-install-recommends install -y \
        # for running scripts
        bash \
        # for building binutils
	    build-essential \
        # for compiling assembly code
	    clang \
        # for creating a bootable ISO
	    grub-pc-bin \
	    # libssl-dev \
        # for linking maestro
	    lld \
	    # perl \
	    # pkg-config \
        # for running maestro
	    qemu-system \
        # for having rust
        rustup \
        # for building binutils
	    texinfo \
        # required by grub to make ISOs
	    xorriso
RUN --mount=type=cache,target=/usr/local/cargo/git/db \
	--mount=type=cache,target=/usr/local/cargo/registry/ \
    rustup default stable && cargo install mdbook mdbook-mermaid

# Build & install binutils
WORKDIR /ld-build
COPY binutils-build.sh .
ADD --checksum=sha256:8608fe44ab7de645f6ad0a898313b75338842490d609adb85c9fb2827c376af2 \
    --unpack=true \
    https://ftp.gnu.org/gnu/binutils/binutils-2.46.0.tar.gz .
RUN ./binutils-build.sh && cd .. && rm -rf /ld-build

# Security: restore base image user & workdir
USER jenkins
WORKDIR /home/jenkins
