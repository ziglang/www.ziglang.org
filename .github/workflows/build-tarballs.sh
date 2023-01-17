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

LAST_SUCCESS=$(curl \
  -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    "https://api.github.com/repos/ziglang/zig/actions/runs?branch=master&status=success&per_page=1&event=push" | jq --raw-output ".workflow_runs[0].head_sha")
git checkout "$LAST_SUCCESS"

ZIG_VERSION="$(zig-ver)"
echo "Last commit with green CI: $LAST_SUCCESS\n Zig version: $ZIG_VERSION"

LAST_TARBALL=$(curl "https://raw.githubusercontent.com/ziglang/www.ziglang.org/master/data/releases.json" | jq --raw-output ".master.version")
echo "Last deployed version: $LAST_TARBALL"

if [ $ZIG_VERSION = $LAST_TARBALL ]; then
  echo "skipped=yes" >> $GITHUB_OUTPUT
  echo "Versions are equal, nothing to do here."
  exit
fi

cd ../..
WORKDIR="$(pwd)"
BOOTSTRAP_SRC="$WORKDIR/zig-bootstrap"
TARBALLS_DIR="$WORKDIR/tarballs"

cd "$BOOTSTRAP_SRC"
git clean -fd
git reset --hard HEAD
git fetch
git checkout origin/master
rm -rf zig
cp -r "$ZIGDIR" ./
sed -i "/^ZIG_VERSION=\".*\"\$/c\\ZIG_VERSION=\"$ZIG_VERSION\"" build

rm -rf out/

# Override the cache directories because they won't actually help other CI runs
# which will be testing alternate versions of zig, and ultimately would just
# fill up space on the hard drive for no reason.
export ZIG_GLOBAL_CACHE_DIR="$(pwd)/out/zig-global-cache"
export ZIG_LOCAL_CACHE_DIR="$(pwd)/out/zig-local-cache"

# NOTE: Debian's cmake (3.18.4) is too old for zig-bootstrap.
CMAKE_GENERATOR=Ninja ./build x86_64-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build x86_64-macos-none baseline
CMAKE_GENERATOR=Ninja ./build aarch64-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build aarch64-macos-none apple_a14
CMAKE_GENERATOR=Ninja ./build riscv64-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build powerpc64le-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build powerpc-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build x86-linux-musl baseline
CMAKE_GENERATOR=Ninja ./build x86_64-windows-gnu baseline
CMAKE_GENERATOR=Ninja ./build aarch64-windows-gnu baseline
CMAKE_GENERATOR=Ninja ./build x86-windows-gnu baseline

# CMAKE_GENERATOR=Ninja ./build arm-linux-musleabihf generic+v7a

ZIG="$BOOTSTRAP_SRC/out/host/bin/zig"

rm -rf "$TARBALLS_DIR"
mkdir "$TARBALLS_DIR"
cd "$TARBALLS_DIR"

cp -r "$ZIGDIR" ./
rm -rf \
  "zig/.github" \
  "zig/.gitignore" \
  "zig/.git" \
  "zig/ci" \
  "zig/CODE_OF_CONDUCT.md" \
  "zig/CONTRIBUTING.md" \
  "zig/.builds" \
  "zig/build" \
  "zig/build-release" \
  "zig/build-debug" \
  "zig/zig-cache"
mv zig "zig-$ZIG_VERSION"
tar cfJ "zig-$ZIG_VERSION.tar.xz" "zig-$ZIG_VERSION"

cd "$BOOTSTRAP_SRC/zig"
"$ZIG" build docs
LANGREF_HTML="$ZIG_LOCAL_CACHE_DIR/langref.html"

# Look for HTML errors.
tidy --drop-empty-elements no -qe "$LANGREF_HTML"

cd "$TARBALLS_DIR"

cp -r $BOOTSTRAP_SRC/out/zig-x86_64-linux-musl-baseline zig-linux-x86_64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86_64-macos-none-baseline zig-macos-x86_64-$ZIG_VERSION/
#cp -r $BOOTSTRAP_SRC/out/zig-x86_64-freebsd-gnu-baseline zig-freebsd-x86_64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-aarch64-linux-musl-baseline zig-linux-aarch64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-aarch64-macos-none-apple_a14 zig-macos-aarch64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86-linux-musl-baseline zig-linux-x86-$ZIG_VERSION/
#cp -r $BOOTSTRAP_SRC/out/zig-arm-linux-musleabihf-generic+v7a zig-linux-armv7a-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-riscv64-linux-musl-baseline zig-linux-riscv64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-powerpc64le-linux-musl-baseline zig-linux-powerpc64le-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-powerpc-linux-musl-baseline zig-linux-powerpc-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86_64-windows-gnu-baseline zig-windows-x86_64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-aarch64-windows-gnu-baseline zig-windows-aarch64-$ZIG_VERSION/
cp -r $BOOTSTRAP_SRC/out/zig-x86-windows-gnu-baseline zig-windows-x86-$ZIG_VERSION/

mv zig-linux-x86_64-$ZIG_VERSION/bin/zig         zig-linux-x86_64-$ZIG_VERSION/zig
mv zig-macos-x86_64-$ZIG_VERSION/bin/zig         zig-macos-x86_64-$ZIG_VERSION/zig
#mv zig-freebsd-x86_64-$ZIG_VERSION/bin/zig      zig-freebsd-x86_64-$ZIG_VERSION/zig
mv zig-linux-aarch64-$ZIG_VERSION/bin/zig        zig-linux-aarch64-$ZIG_VERSION/zig
mv zig-macos-aarch64-$ZIG_VERSION/bin/zig        zig-macos-aarch64-$ZIG_VERSION/zig
mv zig-linux-x86-$ZIG_VERSION/bin/zig            zig-linux-x86-$ZIG_VERSION/zig
#mv zig-linux-armv7a-$ZIG_VERSION/bin/zig        zig-linux-armv7a-$ZIG_VERSION/zig
mv zig-linux-riscv64-$ZIG_VERSION/bin/zig        zig-linux-riscv64-$ZIG_VERSION/zig
mv zig-linux-powerpc64le-$ZIG_VERSION/bin/zig    zig-linux-powerpc64le-$ZIG_VERSION/zig
mv zig-linux-powerpc-$ZIG_VERSION/bin/zig        zig-linux-powerpc-$ZIG_VERSION/zig
mv zig-windows-x86_64-$ZIG_VERSION/bin/zig.exe   zig-windows-x86_64-$ZIG_VERSION/zig.exe
mv zig-windows-aarch64-$ZIG_VERSION/bin/zig.exe  zig-windows-aarch64-$ZIG_VERSION/zig.exe
mv zig-windows-x86-$ZIG_VERSION/bin/zig.exe      zig-windows-x86-$ZIG_VERSION/zig.exe

mv zig-linux-x86_64-$ZIG_VERSION/lib zig-linux-x86_64-$ZIG_VERSION/lib2
mv zig-macos-x86_64-$ZIG_VERSION/lib zig-macos-x86_64-$ZIG_VERSION/lib2
#mv zig-freebsd-x86_64-$ZIG_VERSION/lib zig-freebsd-x86_64-$ZIG_VERSION/lib2
mv zig-linux-aarch64-$ZIG_VERSION/lib zig-linux-aarch64-$ZIG_VERSION/lib2
mv zig-macos-aarch64-$ZIG_VERSION/lib zig-macos-aarch64-$ZIG_VERSION/lib2
mv zig-linux-x86-$ZIG_VERSION/lib zig-linux-x86-$ZIG_VERSION/lib2
#mv zig-linux-armv7a-$ZIG_VERSION/lib zig-linux-armv7a-$ZIG_VERSION/lib2
mv zig-linux-riscv64-$ZIG_VERSION/lib zig-linux-riscv64-$ZIG_VERSION/lib2
mv zig-linux-powerpc64le-$ZIG_VERSION/lib zig-linux-powerpc64le-$ZIG_VERSION/lib2
mv zig-linux-powerpc-$ZIG_VERSION/lib zig-linux-powerpc-$ZIG_VERSION/lib2
mv zig-windows-x86_64-$ZIG_VERSION/lib zig-windows-x86_64-$ZIG_VERSION/lib2
mv zig-windows-aarch64-$ZIG_VERSION/lib zig-windows-aarch64-$ZIG_VERSION/lib2
mv zig-windows-x86-$ZIG_VERSION/lib zig-windows-x86-$ZIG_VERSION/lib2

mv zig-linux-x86_64-$ZIG_VERSION/lib2/zig zig-linux-x86_64-$ZIG_VERSION/lib
mv zig-macos-x86_64-$ZIG_VERSION/lib2/zig zig-macos-x86_64-$ZIG_VERSION/lib
#mv zig-freebsd-x86_64-$ZIG_VERSION/lib2/zig zig-freebsd-x86_64-$ZIG_VERSION/lib
mv zig-linux-aarch64-$ZIG_VERSION/lib2/zig zig-linux-aarch64-$ZIG_VERSION/lib
mv zig-macos-aarch64-$ZIG_VERSION/lib2/zig zig-macos-aarch64-$ZIG_VERSION/lib
mv zig-linux-x86-$ZIG_VERSION/lib2/zig zig-linux-x86-$ZIG_VERSION/lib
#mv zig-linux-armv7a-$ZIG_VERSION/lib2/zig zig-linux-armv7a-$ZIG_VERSION/lib
mv zig-linux-riscv64-$ZIG_VERSION/lib2/zig zig-linux-riscv64-$ZIG_VERSION/lib
mv zig-linux-powerpc64le-$ZIG_VERSION/lib2/zig zig-linux-powerpc64le-$ZIG_VERSION/lib
mv zig-linux-powerpc-$ZIG_VERSION/lib2/zig zig-linux-powerpc-$ZIG_VERSION/lib
mv zig-windows-x86_64-$ZIG_VERSION/lib2/zig zig-windows-x86_64-$ZIG_VERSION/lib
mv zig-windows-aarch64-$ZIG_VERSION/lib2/zig zig-windows-aarch64-$ZIG_VERSION/lib
mv zig-windows-x86-$ZIG_VERSION/lib2/zig zig-windows-x86-$ZIG_VERSION/lib

rmdir zig-linux-x86_64-$ZIG_VERSION/bin zig-linux-x86_64-$ZIG_VERSION/lib2
rmdir zig-macos-x86_64-$ZIG_VERSION/bin zig-macos-x86_64-$ZIG_VERSION/lib2
#rmdir zig-freebsd-x86_64-$ZIG_VERSION/bin zig-freebsd-x86_64-$ZIG_VERSION/lib2
rmdir zig-linux-aarch64-$ZIG_VERSION/bin zig-linux-aarch64-$ZIG_VERSION/lib2
rmdir zig-macos-aarch64-$ZIG_VERSION/bin zig-macos-aarch64-$ZIG_VERSION/lib2
rmdir zig-linux-x86-$ZIG_VERSION/bin zig-linux-x86-$ZIG_VERSION/lib2
#rmdir zig-linux-armv7a-$ZIG_VERSION/bin zig-linux-armv7a-$ZIG_VERSION/lib2
rmdir zig-linux-riscv64-$ZIG_VERSION/bin zig-linux-riscv64-$ZIG_VERSION/lib2
rmdir zig-linux-powerpc64le-$ZIG_VERSION/bin zig-linux-powerpc64le-$ZIG_VERSION/lib2
rmdir zig-linux-powerpc-$ZIG_VERSION/bin zig-linux-powerpc-$ZIG_VERSION/lib2
rmdir zig-windows-x86_64-$ZIG_VERSION/bin zig-windows-x86_64-$ZIG_VERSION/lib2
rmdir zig-windows-aarch64-$ZIG_VERSION/bin zig-windows-aarch64-$ZIG_VERSION/lib2
rmdir zig-windows-x86-$ZIG_VERSION/bin zig-windows-x86-$ZIG_VERSION/lib2

cp $ZIGDIR/LICENSE zig-linux-x86_64-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-macos-x86_64-$ZIG_VERSION/
#cp $ZIGDIR/LICENSE zig-freebsd-x86_64-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-linux-aarch64-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-macos-aarch64-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-linux-x86-$ZIG_VERSION/
#cp $ZIGDIR/LICENSE zig-linux-armv7a-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-linux-riscv64-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-linux-powerpc64le-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-linux-powerpc-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-windows-x86_64-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-windows-aarch64-$ZIG_VERSION/
cp $ZIGDIR/LICENSE zig-windows-x86-$ZIG_VERSION/

mkdir zig-linux-x86_64-$ZIG_VERSION/doc/
mkdir zig-macos-x86_64-$ZIG_VERSION/doc/
#mkdir zig-freebsd-x86_64-$ZIG_VERSION/doc/
mkdir zig-linux-aarch64-$ZIG_VERSION/doc/
mkdir zig-macos-aarch64-$ZIG_VERSION/doc/
mkdir zig-linux-x86-$ZIG_VERSION/doc/
#mkdir zig-linux-armv7a-$ZIG_VERSION/doc/
mkdir zig-linux-riscv64-$ZIG_VERSION/doc/
mkdir zig-linux-powerpc64le-$ZIG_VERSION/doc/
mkdir zig-linux-powerpc-$ZIG_VERSION/doc/
mkdir zig-windows-x86_64-$ZIG_VERSION/doc/
mkdir zig-windows-aarch64-$ZIG_VERSION/doc/
mkdir zig-windows-x86-$ZIG_VERSION/doc/

"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target x86_64-linux-musl   -femit-docs="zig-linux-x86_64-$ZIG_VERSION/doc/std"    -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target x86_64-macos        -femit-docs="zig-macos-x86_64-$ZIG_VERSION/doc/std"    -fno-emit-bin
#"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target x86_64-freebsd     -femit-docs="zig-freebsd-x86_64-$ZIG_VERSION/doc/std"  -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target aarch64-linux-musl  -femit-docs="zig-linux-aarch64-$ZIG_VERSION/doc/std"   -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target aarch64-macos       -femit-docs="zig-macos-aarch64-$ZIG_VERSION/doc/std"   -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target x86-linux-musl      -femit-docs="zig-linux-x86-$ZIG_VERSION/doc/std"       -fno-emit-bin
#"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target arm-linux-musl -mcpu=generic+v7a  -femit-docs="zig-linux-armv7a-$ZIG_VERSION/doc/std" -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target riscv64-linux-musl  -femit-docs="zig-linux-riscv64-$ZIG_VERSION/doc/std"   -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target powerpc64le-linux-musl -femit-docs="zig-linux-powerpc64le-$ZIG_VERSION/doc/std" -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target powerpc-linux-musl  -femit-docs="zig-linux-powerpc-$ZIG_VERSION/doc/std"   -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target x86_64-windows-gnu  -femit-docs="zig-windows-x86_64-$ZIG_VERSION/doc/std"  -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target aarch64-windows-gnu -femit-docs="zig-windows-aarch64-$ZIG_VERSION/doc/std" -fno-emit-bin
"$ZIG" test "$BOOTSTRAP_SRC/zig/lib/std/std.zig" --zig-lib-dir "$BOOTSTRAP_SRC/zig/lib" -target x86-windows-gnu     -femit-docs="zig-windows-x86-$ZIG_VERSION/doc/std"     -fno-emit-bin

cp $LANGREF_HTML zig-linux-x86_64-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-macos-x86_64-$ZIG_VERSION/doc/
#cp $LANGREF_HTML zig-freebsd-x86_64-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-linux-aarch64-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-macos-aarch64-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-linux-x86-$ZIG_VERSION/doc/
#cp $LANGREF_HTML zig-linux-armv7a-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-linux-riscv64-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-linux-powerpc64le-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-linux-powerpc-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-windows-x86_64-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-windows-aarch64-$ZIG_VERSION/doc/
cp $LANGREF_HTML zig-windows-x86-$ZIG_VERSION/doc/

tar cJf zig-linux-x86_64-$ZIG_VERSION.tar.xz zig-linux-x86_64-$ZIG_VERSION/
tar cJf zig-macos-x86_64-$ZIG_VERSION.tar.xz zig-macos-x86_64-$ZIG_VERSION/
#tar cJf zig-freebsd-x86_64-$ZIG_VERSION.tar.xz zig-freebsd-x86_64-$ZIG_VERSION/
tar cJf zig-linux-aarch64-$ZIG_VERSION.tar.xz zig-linux-aarch64-$ZIG_VERSION/
tar cJf zig-macos-aarch64-$ZIG_VERSION.tar.xz zig-macos-aarch64-$ZIG_VERSION/
tar cJf zig-linux-x86-$ZIG_VERSION.tar.xz zig-linux-x86-$ZIG_VERSION/
#tar cJf zig-linux-armv7a-$ZIG_VERSION.tar.xz zig-linux-armv7a-$ZIG_VERSION/
tar cJf zig-linux-riscv64-$ZIG_VERSION.tar.xz zig-linux-riscv64-$ZIG_VERSION/
tar cJf zig-linux-powerpc64le-$ZIG_VERSION.tar.xz zig-linux-powerpc64le-$ZIG_VERSION/
tar cJf zig-linux-powerpc-$ZIG_VERSION.tar.xz zig-linux-powerpc-$ZIG_VERSION/
7z a zig-windows-x86_64-$ZIG_VERSION.zip zig-windows-x86_64-$ZIG_VERSION/
7z a zig-windows-aarch64-$ZIG_VERSION.zip zig-windows-aarch64-$ZIG_VERSION/
7z a zig-windows-x86-$ZIG_VERSION.zip zig-windows-x86-$ZIG_VERSION/

echo | minisign -Sm zig-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-x86_64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-macos-x86_64-$ZIG_VERSION.tar.xz
#echo | minisign -Sm zig-freebsd-x86_64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-aarch64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-macos-aarch64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-x86-$ZIG_VERSION.tar.xz
#echo | minisign -Sm zig-linux-armv7a-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-riscv64-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-powerpc64le-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-linux-powerpc-$ZIG_VERSION.tar.xz
echo | minisign -Sm zig-windows-x86_64-$ZIG_VERSION.zip
echo | minisign -Sm zig-windows-aarch64-$ZIG_VERSION.zip
echo | minisign -Sm zig-windows-x86-$ZIG_VERSION.zip

s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-bootstrap-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86_64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-x86_64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-freebsd-x86_64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-aarch64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-aarch64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-armv7a-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-riscv64-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc64le-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc-$ZIG_VERSION.tar.xz s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86_64-$ZIG_VERSION.zip s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-aarch64-$ZIG_VERSION.zip s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86-$ZIG_VERSION.zip s3://ziglang.org/builds/

s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-bootstrap-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86_64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-x86_64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-freebsd-x86_64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-aarch64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-macos-aarch64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-x86-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
#s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-armv7a-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-riscv64-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc64le-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-linux-powerpc-$ZIG_VERSION.tar.xz.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86_64-$ZIG_VERSION.zip.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-aarch64-$ZIG_VERSION.zip.minisig s3://ziglang.org/builds/
s3cmd put -P --add-header="cache-control: public, max-age=31536000, immutable" zig-windows-x86-$ZIG_VERSION.zip.minisig s3://ziglang.org/builds/

export SRC_TARBALL="zig-$ZIG_VERSION.tar.xz"
export SRC_SHASUM=$(sha256sum "zig-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)
export SRC_BYTESIZE=$(wc -c < "zig-$ZIG_VERSION.tar.xz")

export X86_64_LINUX_TARBALL="zig-linux-x86_64-$ZIG_VERSION.tar.xz"
export X86_64_LINUX_BYTESIZE=$(wc -c < "zig-linux-x86_64-$ZIG_VERSION.tar.xz")
export X86_64_LINUX_SHASUM="$(sha256sum "zig-linux-x86_64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export X86_64_MACOS_TARBALL="zig-macos-x86_64-$ZIG_VERSION.tar.xz"
export X86_64_MACOS_BYTESIZE=$(wc -c < "zig-macos-x86_64-$ZIG_VERSION.tar.xz")
export X86_64_MACOS_SHASUM="$(sha256sum "zig-macos-x86_64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

export AARCH64_LINUX_TARBALL="zig-linux-aarch64-$ZIG_VERSION.tar.xz"
export AARCH64_LINUX_BYTESIZE=$(wc -c < "zig-linux-aarch64-$ZIG_VERSION.tar.xz")
export AARCH64_LINUX_SHASUM="$(sha256sum "zig-linux-aarch64-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

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

export POWERPC_LINUX_TARBALL="zig-linux-powerpc-$ZIG_VERSION.tar.xz"
export POWERPC_LINUX_BYTESIZE=$(wc -c < "zig-linux-powerpc-$ZIG_VERSION.tar.xz")
export POWERPC_LINUX_SHASUM="$(sha256sum "zig-linux-powerpc-$ZIG_VERSION.tar.xz" | cut '-d ' -f1)"

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

mv out/index.json "$WEBSITEDIR/data/releases.json"
cd "$WEBSITEDIR"

# This is the user when pushing to the website repo.
git config user.email "ziggy@ziglang.org"
git config user.name "Ziggy"

git add data/releases.json
git commit -m "CI: update master branch builds"
git push

# Update autodocs and langref directly to S3 in order to prevent the
# www.ziglang.org git repo from growing too big.

# Please do not edit this script to pre-compress the artifacts before they hit
# S3. This prevents the website from working on browsers that do not support gzip
# encoding. Cloudfront will automatically compress files if they are less than
# 9.5 MiB, and the client advertises itself as capable of decompressing.
# The data.js file is currently 16 MiB. In order to fix this problem, we need to do
# one of the following things:
# * Reduce the size of data.js to less than 9.5 MiB.
# * Figure out how to adjust the Cloudfront settings to increase the max size for
#   auto-compressed objects.
# * Migrate to fastly.
DOCDIR="$TARBALLS_DIR/zig-linux-x86_64-$ZIG_VERSION/doc"
s3cmd put -P --no-mime-magic \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$LANGREF_HTML" s3://ziglang.org/documentation/master/index.html

s3cmd put -P --no-mime-magic \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/std/index.html" s3://ziglang.org/documentation/master/std/index.html

s3cmd put -P --no-mime-magic \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/std/main.js" s3://ziglang.org/documentation/master/std/main.js

s3cmd put -P --no-mime-magic \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  "$DOCDIR/std/data.js" s3://ziglang.org/documentation/master/std/data.js

s3cmd put -P --no-mime-magic --recursive \
  --add-header="Cache-Control: max-age=0, must-revalidate" \
  -m "text/html" \
  "$DOCDIR/std/src/" s3://ziglang.org/documentation/master/std/src/
