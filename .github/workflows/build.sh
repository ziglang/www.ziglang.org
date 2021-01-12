#!/bin/sh

set -x
set -e

START_DIR=$(pwd)
ZIG_DOWNLOAD_URL=$(cat data/releases.json | jq -r '.master."x86_64-linux".tarball')
cd ..

# Download latest Zig and add it to PATH
mkdir zig
wget -qO zig.tar.xf "$ZIG_DOWNLOAD_URL"
tar -C zig --strip-components=1 -xJf zig.tar.xf
export PATH=$PATH:$(pwd)/zig

# Download latest Doctest, build it and add it to PATH
mkdir doctest
wget -qO doctest.tar "https://api.github.com/repos/kristoff-it/zig-doctest/tarball/"
tar -C doctest --strip-components=1 -xvf doctest.tar 
cd doctest
zig build
export PATH=$PATH:$(pwd)/zig-cache/bin
cd ..

# Download Go and add it to PATH
wget -qO go.tar.gz "https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz"
tar -xzf go.tar.gz
export GOROOT=$(pwd)/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Get our Hugo fork, build it and add it to PATH
mkdir hugo
wget -qO hugo.tar "https://api.github.com/repos/kristoff-it/hugo/tarball/"
tar -C hugo --strip-components=1 -xf hugo.tar 
cd hugo
CGO_ENABLED=1 go build --tags extended
cd ..

# Share the changes to $PATH to other workflows
echo "$PATH" > $GITHUB_ENV

# go back to the website 
cd "$START_DIR"
