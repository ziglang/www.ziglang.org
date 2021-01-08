#!/bin/sh

set -x
set -e

apt-get update 
apt-get install -y jq wget xz-utils gcc

# The github action left us inside a checkout of www.ziglang.org (workspace)
cd .. 

# Download latest Zig and add it to PATH
mkdir zig
wget -qO zig.tar.xf $(cat ./workspace/data/releases.json | jq -r '.master."x86_64-linux".tarball')
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
tar -xzvf go.tar.gz
export GOROOT=$(pwd)/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Get our Hugo fork, build it and add it to PATH
mkdir hugo
wget -qO hugo.tar "https://api.github.com/repos/kristoff-it/hugo/tarball/"
tar -C hugo --strip-components=1 -xvf hugo.tar 
cd hugo
CGO_ENABLED=1 go install --tags extended
cd ..

# go back to the website
cd workspace

