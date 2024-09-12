#!/bin/sh

set -x
set -e

export PATH="$HOME/local/bin:$PATH"

WEBSITEDIR="$(pwd)"
cd ../zig
ZIGDIR="$(pwd)"
# Make the `zig version` number consistent.
# This will affect the zig-ver command below.
git config core.abbrev 9
git fetch --unshallow || true
git fetch --tags


if [ -z "$ZIG_RELEASE_TAG" ]; then
  LAST_SUCCESS=$(curl \
    -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_TOKEN" \
      "https://api.github.com/repos/ziglang/zig/actions/runs?branch=master&status=success&per_page=1&event=push" | jq --raw-output ".workflow_runs[0].head_sha")
  git checkout "$LAST_SUCCESS"

  ZIG_VERSION="$(zig-ver)"
  echo "Last commit with green CI: $LAST_SUCCESS\n Zig version: $ZIG_VERSION"

  LAST_TARBALL=$(curl "https://raw.githubusercontent.com/ziglang/www.ziglang.org/main/assets/download/index.json" | jq --raw-output ".master.version")
  echo "Last deployed version: $LAST_TARBALL"

  if [ $ZIG_VERSION = $LAST_TARBALL ]; then
    echo "skipped=yes" >> $GITHUB_OUTPUT
    echo "Versions are equal, nothing to do here."
    exit
  fi
else
  # Prevent website deploy
  echo "skipped=yes" >> $GITHUB_OUTPUT
  git checkout "$ZIG_RELEASE_TAG"
  ZIG_VERSION="$ZIG_RELEASE_TAG"
  echo "Building version from tag: $ZIG_VERSION"
fi

cd ../..
WORKDIR="$(pwd)"
BOOTSTRAP_SRC="$WORKDIR/zig-bootstrap"
TARBALLS_DIR="$WORKDIR/tarballs"

rm -rf "$TARBALLS_DIR"
mkdir "$TARBALLS_DIR"
cd "$TARBALLS_DIR"

cp -r "$ZIGDIR" ./
rm -rf \
  "zig/.github" \
  "zig/.gitignore" \
  "zig/.gitattributes" \
  "zig/.git" \
  "zig/.mailmap" \
  "zig/ci" \
  "zig/build" \
  "zig/build-release" \
  "zig/build-debug" \
  "zig/zig-cache"
mv zig "zig-$ZIG_VERSION"
XZ_OPT=-9 tar cfJ "zig-$ZIG_VERSION.tar.xz" "zig-$ZIG_VERSION" --sort=name

cd "$BOOTSTRAP_SRC"
git clean -fd
git reset --hard HEAD
git fetch

if [ -z "$ZIG_BOOTSTRAP_BRANCH" ]; then
  git checkout origin/master
else
  git checkout "origin/$ZIG_BOOTSTRAP_BRANCH"
fi

rm -rf zig
cp -r "$TARBALLS_DIR/zig-$ZIG_VERSION" zig
sed -i "/^ZIG_VERSION=\".*\"\$/c\\ZIG_VERSION=\"$ZIG_VERSION\"" build
sed -i "/^ \* zig /c\\ * zig $ZIG_VERSION" README.md
rm -rf out/

cd "$TARBALLS_DIR"
cp -r "$BOOTSTRAP_SRC" "zig-bootstrap-$ZIG_VERSION"
rm -rf \
  "zig-bootstrap-$ZIG_VERSION/.git" \
  "zig-bootstrap-$ZIG_VERSION/.gitattributes" \
  "zig-bootstrap-$ZIG_VERSION/.github" \
  "zig-bootstrap-$ZIG_VERSION/.gitignore"

XZ_OPT=-9 tar cfJ "zig-bootstrap-$ZIG_VERSION.tar.xz" "zig-bootstrap-$ZIG_VERSION" --sort=name

# Override the cache directories because they won't actually help other CI runs
# which will be testing alternate versions of zig, and ultimately would just
# fill up space on the hard drive for no reason.
export ZIG_GLOBAL_CACHE_DIR="$BOOTSTRAP_SRC/out/zig-global-cache"
export ZIG_LOCAL_CACHE_DIR="$BOOTSTRAP_SRC/out/zig-local-cache"

cd "$BOOTSTRAP_SRC"
# NOTE: Debian's cmake (3.18.4) is too old for zig-bootstrap.
CMAKE_GENERATOR=Ninja ./build x86_64-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build x86_64-macos-none baseline
CMAKE_GENERATOR=Ninja ./build aarch64-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build aarch64-macos-none apple_a14
CMAKE_GENERATOR=Ninja ./build riscv64-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build powerpc64le-linux-musl baseline
#CMAKE_GENERATOR=Ninja ./build powerpc-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build x86-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build x86_64-windows-gnu baseline
CMAKE_GENERATOR=Ninja ./build aarch64-windows-gnu baseline
CMAKE_GENERATOR=Ninja ./build x86-windows-gnu baseline
CMAKE_GENERATOR=Ninja ./build arm-linux-musleabihf generic+v7a

ZIG="$BOOTSTRAP_SRC/out/host/bin/zig"

cd "$TARBALLS_DIR"

cp -r $BOOTSTRAP_SRC/out/zig-x86_64-linux-musl-baseline zig-linux-x86_64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86_64-macos-none-baseline zig-macos-x86_64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-aarch64-linux-musl-baseline zig-linux-aarch64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-aarch64-macos-none-apple_a14 zig-macos-aarch64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86-linux-musl-baseline zig-linux-x86-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-arm-linux-musleabihf-generic+v7a zig-linux-armv7a-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-riscv64-linux-musl-baseline zig-linux-riscv64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-powerpc64le-linux-musl-baseline zig-linux-powerpc64le-$ZIG_VERSION/
#cp -r $BOOTSTRAP_SRC/out/zig-powerpc-linux-musl-baseline zig-linux-powerpc-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86_64-windows-gnu-baseline zig-windows-x86_64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-aarch64-windows-gnu-baseline zig-windows-aarch64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86-windows-gnu-baseline zig-windows-x86-$ZIG_VERSION/
#cp -r $BOOTSTRAP_SRC/out/zig-x86_64-freebsd-gnu-baseline zig-freebsd-x86_64-$ZIG_VERSION/

XZ_OPT=-9 tar cJf zig-linux-x86_64-$ZIG_VERSION.tar.xz zig-linux-x86_64-$ZIG_VERSION/ --sort=name
XZ_OPT=-9 tar cJf zig-macos-x86_64-$ZIG_VERSION.tar.xz zig-macos-x86_64-$ZIG_VERSION/ --sort=name
XZ_OPT=-9 tar cJf zig-linux-aarch64-$ZIG_VERSION.tar.xz zig-linux-aarch64-$ZIG_VERSION/ --sort=name
XZ_OPT=-9 tar cJf zig-macos-aarch64-$ZIG_VERSION.tar.xz zig-macos-aarch64-$ZIG_VERSION/ --sort=name
XZ_OPT=-9 tar cJf zig-linux-x86-$ZIG_VERSION.tar.xz zig-linux-x86-$ZIG_VERSION/ --sort=name
XZ_OPT=-9 tar cJf zig-linux-armv7a-$ZIG_VERSION.tar.xz zig-linux-armv7a-$ZIG_VERSION/ --sort=name
XZ_OPT=-9 tar cJf zig-linux-riscv64-$ZIG_VERSION.tar.xz zig-linux-riscv64-$ZIG_VERSION/ --sort=name
XZ_OPT=-9 tar cJf zig-linux-powerpc64le-$ZIG_VERSION.tar.xz zig-linux-powerpc64le-$ZIG_VERSION/ --sort=name
#XZ_OPT=-9 tar cJf zig-linux-powerpc-$ZIG_VERSION.tar.xz zig-linux-powerpc-$ZIG_VERSION/ --sort=name
7z a zig-windows-x86_64-$ZIG_VERSION.zip zig-windows-x86_64-$ZIG_VERSION/
7z a zig-windows-aarch64-$ZIG_VERSION.zip zig-windows-aarch64-$ZIG_VERSION/
7z a zig-windows-x86-$ZIG_VERSION.zip zig-windows-x86-$ZIG_VERSION/
#XZ_OPT=-9 tar cJf zig-freebsd-x86_64-$ZIG_VERSION.tar.xz zig-freebsd-x86_64-$ZIG_VERSION/ --sort=name

echo | minisign -Sm zig-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-bootstrap-$ZIG_VERSION.tar.xz

echo | minisign -Sm zig-linux-x86_64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-macos-x86_64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-aarch64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-macos-aarch64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-x86-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-armv7a-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-riscv64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-powerpc64le-$ZIG_VERSION.tar.xz
#echo | minisign -Sm zig-linux-powerpc-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-windows-x86_64-$ZIG_VERSION.zip
echo | minisign -Sm zig-windows-aarch64-$ZIG_VERSION.zip
echo | minisign -Sm zig-windows-x86-$ZIG_VERSION.zip
#echo | minisign -Sm zig-freebsd-x86_64-$ZIG_VERSION.tar.xz

# Delete builds older than 30 days so the server does not run out of disk space.
WWW_PREFIX="/var/www/html"
find $WWW_PREFIX/* -ctime +30 -exec rm -rf {} \;
mkdir -p "$WWW_PREFIX/builds"

cp zig-$ZIG_VERSION.tar.xz                            "$WWW_PREFIX/builds/"
cp zig-bootstrap-$ZIG_VERSION.tar.xz                  "$WWW_PREFIX/builds/"
cp zig-linux-x86_64-$ZIG_VERSION.tar.xz               "$WWW_PREFIX/builds/"
cp zig-macos-x86_64-$ZIG_VERSION.tar.xz               "$WWW_PREFIX/builds/"
cp zig-linux-aarch64-$ZIG_VERSION.tar.xz              "$WWW_PREFIX/builds/"
cp zig-macos-aarch64-$ZIG_VERSION.tar.xz              "$WWW_PREFIX/builds/"
cp zig-linux-x86-$ZIG_VERSION.tar.xz                  "$WWW_PREFIX/builds/"
cp zig-linux-armv7a-$ZIG_VERSION.tar.xz               "$WWW_PREFIX/builds/"
cp zig-linux-riscv64-$ZIG_VERSION.tar.xz              "$WWW_PREFIX/builds/"
cp zig-linux-powerpc64le-$ZIG_VERSION.tar.xz          "$WWW_PREFIX/builds/"
cp zig-windows-x86_64-$ZIG_VERSION.zip                "$WWW_PREFIX/builds/"
cp zig-windows-aarch64-$ZIG_VERSION.zip               "$WWW_PREFIX/builds/"
cp zig-windows-x86-$ZIG_VERSION.zip                   "$WWW_PREFIX/builds/"
cp zig-$ZIG_VERSION.tar.xz.minisig                    "$WWW_PREFIX/builds/"
cp zig-bootstrap-$ZIG_VERSION.tar.xz.minisig          "$WWW_PREFIX/builds/"
cp zig-linux-x86_64-$ZIG_VERSION.tar.xz.minisig       "$WWW_PREFIX/builds/"
cp zig-macos-x86_64-$ZIG_VERSION.tar.xz.minisig       "$WWW_PREFIX/builds/"
cp zig-linux-aarch64-$ZIG_VERSION.tar.xz.minisig      "$WWW_PREFIX/builds/"
cp zig-macos-aarch64-$ZIG_VERSION.tar.xz.minisig      "$WWW_PREFIX/builds/"
cp zig-linux-x86-$ZIG_VERSION.tar.xz.minisig          "$WWW_PREFIX/builds/"
cp zig-linux-armv7a-$ZIG_VERSION.tar.xz.minisig       "$WWW_PREFIX/builds/"
cp zig-linux-riscv64-$ZIG_VERSION.tar.xz.minisig      "$WWW_PREFIX/builds/"
cp zig-linux-powerpc64le-$ZIG_VERSION.tar.xz.minisig  "$WWW_PREFIX/builds/"
cp zig-windows-x86_64-$ZIG_VERSION.zip.minisig        "$WWW_PREFIX/builds/"
cp zig-windows-aarch64-$ZIG_VERSION.zip.minisig       "$WWW_PREFIX/builds/"
cp zig-windows-x86-$ZIG_VERSION.zip.minisig           "$WWW_PREFIX/builds/"


s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-bootstrap-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/

s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86_64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-x86_64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-freebsd-x86_64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-aarch64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-aarch64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-armv7a-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-riscv64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc64le-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86_64-$ZIG_VERSION.zip s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-aarch64-$ZIG_VERSION.zip s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86-$ZIG_VERSION.zip s3://ziglang.org/builds/

s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-bootstrap-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86_64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-x86_64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-freebsd-x86_64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-aarch64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-aarch64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-armv7a-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-riscv64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc64le-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86_64-$ZIG_VERSION.zip.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-aarch64-$ZIG_VERSION.zip.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86-$ZIG_VERSION.zip.minisig s3://ziglang.org/builds/

export SRC_TARBALL="zig-$ZIG_VERSION.tar.xz"
export SRC_SHASUM=$(sha256sum "zig-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)
export SRC_BYTESIZE=$(wc -c < "zig-$ZIG_VERSION.tar.xz")

export BOOTSTRAP_TARBALL="zig-bootstrap-$ZIG_VERSION.tar.xz"
export BOOTSTRAP_SHASUM=$(sha256sum "zig-bootstrap-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)
export BOOTSTRAP_BYTESIZE=$(wc -c < "zig-bootstrap-$ZIG_VERSION.tar.xz")

export X86_64_LINUX_TARBALL="zig-linux-x86_64-$ZIG_VERSION.tar.xz"
export X86_64_LINUX_BYTESIZE=$(wc -c < "zig-linux-x86_64-$ZIG_VERSION.tar.xz")
export X86_64_LINUX_SHASUM="$(sha256sum "zig-linux-x86_64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export X86_64_MACOS_TARBALL="zig-macos-x86_64-$ZIG_VERSION.tar.xz"
export X86_64_MACOS_BYTESIZE=$(wc -c < "zig-macos-x86_64-$ZIG_VERSION.tar.xz")
export X86_64_MACOS_SHASUM="$(sha256sum "zig-macos-x86_64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export AARCH64_LINUX_TARBALL="zig-linux-aarch64-$ZIG_VERSION.tar.xz"
export AARCH64_LINUX_BYTESIZE=$(wc -c < "zig-linux-aarch64-$ZIG_VERSION.tar.xz")
export AARCH64_LINUX_SHASUM="$(sha256sum "zig-linux-aarch64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export ARMV7A_LINUX_TARBALL="zig-linux-armv7a-$ZIG_VERSION.tar.xz"
export ARMV7A_LINUX_BYTESIZE=$(wc -c < "zig-linux-armv7a-$ZIG_VERSION.tar.xz")
export ARMV7A_LINUX_SHASUM="$(sha256sum "zig-linux-armv7a-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export AARCH64_MACOS_TARBALL="zig-macos-aarch64-$ZIG_VERSION.tar.xz"
export AARCH64_MACOS_BYTESIZE=$(wc -c < "zig-macos-aarch64-$ZIG_VERSION.tar.xz")
export AARCH64_MACOS_SHASUM="$(sha256sum "zig-macos-aarch64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

#export X86_64_FREEBSD_TARBALL="zig-freebsd-x86_64-$ZIG_VERSION.tar.xz"
#export X86_64_FREEBSD_BYTESIZE=$(wc -c < "zig-freebsd-x86_64-$ZIG_VERSION.tar.xz")
#export X86_64_FREEBSD_SHASUM="$(sha256sum "zig-freebsd-x86_64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

#export X86_64_NETBSD_TARBALL="zig-netbsd-x86_64-$ZIG_VERSION.tar.xz"
#export X86_64_NETBSD_BYTESIZE=$(wc -c < "zig-netbsd-x86_64-$ZIG_VERSION.tar.xz")
#export X86_64_NETBSD_SHASUM="$(sha256sum "zig-netbsd-x86_64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export RISCV64_LINUX_TARBALL="zig-linux-riscv64-$ZIG_VERSION.tar.xz"
export RISCV64_LINUX_BYTESIZE=$(wc -c < "zig-linux-riscv64-$ZIG_VERSION.tar.xz")
export RISCV64_LINUX_SHASUM="$(sha256sum "zig-linux-riscv64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export POWERPC64LE_LINUX_TARBALL="zig-linux-powerpc64le-$ZIG_VERSION.tar.xz"
export POWERPC64LE_LINUX_BYTESIZE=$(wc -c < "zig-linux-powerpc64le-$ZIG_VERSION.tar.xz")
export POWERPC64LE_LINUX_SHASUM="$(sha256sum "zig-linux-powerpc64le-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

#export POWERPC_LINUX_TARBALL="zig-linux-powerpc-$ZIG_VERSION.tar.xz"
#export POWERPC_LINUX_BYTESIZE=$(wc -c < "zig-linux-powerpc-$ZIG_VERSION.tar.xz")
#export POWERPC_LINUX_SHASUM="$(sha256sum "zig-linux-powerpc-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export X86_LINUX_TARBALL="zig-linux-x86-$ZIG_VERSION.tar.xz"
export X86_LINUX_BYTESIZE=$(wc -c < "zig-linux-x86-$ZIG_VERSION.tar.xz")
export X86_LINUX_SHASUM="$(sha256sum "zig-linux-x86-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export X86_64_WINDOWS_TARBALL="zig-windows-x86_64-$ZIG_VERSION.zip"
export X86_64_WINDOWS_BYTESIZE=$(wc -c < "zig-windows-x86_64-$ZIG_VERSION.zip")
export X86_64_WINDOWS_SHASUM="$(sha256sum "zig-windows-x86_64-$ZIG_VERSION.zip" | cut '-d ' -f1)"

export AARCH64_WINDOWS_TARBALL="zig-windows-aarch64-$ZIG_VERSION.zip"
export AARCH64_WINDOWS_BYTESIZE=$(wc -c < "zig-windows-aarch64-$ZIG_VERSION.zip")
export AARCH64_WINDOWS_SHASUM="$(sha256sum "zig-windows-aarch64-$ZIG_VERSION.zip" | cut '-d ' -f1)"

export X86_WINDOWS_TARBALL="zig-windows-x86-$ZIG_VERSION.zip"
export X86_WINDOWS_BYTESIZE=$(wc -c < "zig-windows-x86-$ZIG_VERSION.zip")
export X86_WINDOWS_SHASUM="$(sha256sum "zig-windows-x86-$ZIG_VERSION.zip" | cut '-d ' -f1)"

export MASTER_DATE="$(date +%Y-%m-%d)"
export MASTER_VERSION="$ZIG_VERSION"

# Create index.json and update the website repo.
cd "$WEBSITEDIR/.github/workflows"
# Pull before modifying tracked files in case new updates
# have been pushed to the repository (very possible since
# this is a long-running process).
git pull
"$ZIG" run update-download-page.zig

echo | minisign -Sm out/index.json
s3cmd put -P \
  --add-header="cache-control: public, max-age=31536000, immutable" \
  out/index.json.minisig \
  s3://ziglang.org/builds/zig-$ZIG_VERSION-index.json.minisig

cp out/index.json.minisig "$WWW_PREFIX/builds/zig-$ZIG_VERSION-index.json.minisig"

mv out/index.json "$WEBSITEDIR/assets/download/index.json"
cd "$WEBSITEDIR"

# This is the user when pushing to the website repo.
git config user.email "ziggy@ziglang.org"
git config user.name "Ziggy"

git add assets/download/index.json
git commit -m "CI: update master branch builds"
git push

# Update autodocs and langref directly to S3 in order to prevent the
# www.ziglang.org git repo from growing too big.
DOCDIR="$TARBALLS_DIR/zig-linux-x86_64-$ZIG_VERSION/doc"
s3cmd put -P --no-mime-magic \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/langref.html" s3://ziglang.org/documentation/master/index.html

mkdir -p "$WWW_PREFIX/documentation/master"
cp "$DOCDIR/langref.html" "$WWW_PREFIX/documentation/master/index.html"

# Standard library autodocs are intentionally excluded from tarballs of Zig but
# we want to host them on the website.
"$ZIG" build-obj -fno-emit-bin -femit-docs="$DOCDIR/std" "$BOOTSTRAP_SRC/zig/lib/std/std.zig"

# Cloudfront will automatically compress some kinds of files if they are less
# than 9.5 MiB, and the client advertises itself as capable of decompressing.
# Tar files are not included in this list unfortunately, and, there is no way
# to change the settings in Cloudfront.
#
# Until we migrate to a different static website file hosting service, this logic
# stores the files compressed on S3 with the gzip HTTP header hard-coded.
gzip -c -9 "$DOCDIR/std/index.html"  > "$DOCDIR/std/index.html.gz"
gzip -c -9 "$DOCDIR/std/main.js"     > "$DOCDIR/std/main.js.gz"
gzip -c -9 "$DOCDIR/std/main.wasm"   > "$DOCDIR/std/main.wasm.gz"
gzip -c -9 "$DOCDIR/std/sources.tar" > "$DOCDIR/std/sources.tar.gz"

s3cmd put -P --no-mime-magic \
  --add-header="Content-Encoding: gzip" \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/std/index.html.gz" s3://ziglang.org/documentation/master/std/index.html

s3cmd put -P --no-mime-magic \
  --add-header="Content-Encoding: gzip" \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/std/main.js.gz" s3://ziglang.org/documentation/master/std/main.js

s3cmd put -P --no-mime-magic \
  --add-header="Content-Encoding: gzip" \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/std/main.wasm.gz" s3://ziglang.org/documentation/master/std/main.wasm

s3cmd put -P --no-mime-magic \
  --add-header="Content-Encoding: gzip" \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/std/sources.tar.gz" s3://ziglang.org/documentation/master/std/sources.tar


mkdir -p "$WWW_PREFIX/documentation/master/std"
cp "$DOCDIR/std/index.html.gz" "$WWW_PREFIX/documentation/master/std/index.html.gz"
cp "$DOCDIR/std/main.js.gz" "$WWW_PREFIX/documentation/master/std/main.js.gz"
cp "$DOCDIR/std/main.wasm.gz" "$WWW_PREFIX/documentation/master/std/main.wasm.gz"
cp "$DOCDIR/std/sources.tar.gz" "$WWW_PREFIX/documentation/master/std/sources.tar.gz"


