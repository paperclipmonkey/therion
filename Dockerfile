# Therion in a container, for headless map builds in CI.
#
#   docker run --rm -v "$PWD:/project" ghcr.io/paperclipmonkey/therion:latest thconfig
#
# Only the `therion` command line tool is built. loch (the 3D viewer) and
# xtherion (the Tk editor) are GUI programs with no use in a container,
# and turning them off drops VTK, wxWidgets and Tcl from the image
# entirely. thbook.pdf is the manual -- also not needed here.
#
# Kept deliberately, because downstream builds depend on them:
#   texlive-binaries    pdftex, and pltotf for custom map fonts
#   lcdf-typetools      otftotfm, for `pdf-fonts` in therion.ini
#   texlive-metapost    map rendering
#   ghostscript         PDF post-processing and page previews
#   python3             for repositories that generate an index page
#   libshp-dev          ESRI shapefile export
#   survex              loop closure
#   tcl                 thcsdata.tcl generates the coordinate-system tables
#                       at build time -- needed even with xtherion off

FROM ubuntu:noble AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      ca-certificates \
      catch2 \
      cmake \
      g++ \
      geographiclib-tools \
      gettext \
      git \
      ghostscript \
      imagemagick \
      lcdf-typetools \
      libfmt-dev \
      libjpeg-dev \
      libpng-dev \
      libproj-dev \
      libshp-dev \
      ninja-build \
      pkg-config \
      python3 \
      survex \
      tcl \
      texlive-binaries \
      texlive-lang-cyrillic \
      texlive-lang-czechslovak \
      texlive-metapost \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /src
WORKDIR /src

# -Wno-array-bounds / -Wno-stringop-overflow match what upstream's own
# Ubuntu 24.04 GCC job passes; without them the build trips over
# false positives in GCC 13.
RUN cmake -S . -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_THERION=ON \
      -DBUILD_LOCH=OFF \
      -DBUILD_XTHERION=OFF \
      -DBUILD_THBOOK=OFF \
      -DUSE_BUNDLED_SHAPELIB=OFF \
      -DCMAKE_CXX_FLAGS="-Wno-array-bounds -Wno-stringop-overflow" \
 && cmake --build build \
 && cmake --build build -t install \
 && therion --version

WORKDIR /project
ENTRYPOINT ["therion"]
