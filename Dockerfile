FROM mcr.microsoft.com/devcontainers/base:noble AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y \
    bash-completion \
    bwidget \
    catch2 \
    clang \
    clang-tidy \
    cmake \
    g++ \
    ghostscript \
    git \
    imagemagick \
    lcdf-typetools \
    libfmt-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libproj-dev \
    libtk-img-dev \
    libvtk9-dev \
    libwxgtk3.2-dev \
    ninja-build \
    python3 \
    survex \
    tcl-dev \
    texlive-binaries \
    texlive-lang-cyrillic \
    texlive-lang-czechslovak \
    texlive-metapost \
    zlib1g-dev
COPY . /project
WORKDIR /project
RUN make config-debian && make && make install

# FROM ubuntu:noble AS release
# COPY --from=build /project/therion /usr/therion
ENTRYPOINT ["therion"]
