#!/bin/sh

set -x
set -e

s3cmd put -P --no-mime-magic --recursive --add-header="Cache-Control: max-age=0, must-revalidate" "public/" "s3://ziglang.org/"
