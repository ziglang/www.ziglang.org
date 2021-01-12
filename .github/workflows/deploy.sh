#!/bin/sh

set -x
set -e

s3cmd sync -P --no-mime-magic --add-header="Cache-Control: max-age=0, must-revalidate" "public/" "s3://ziglang.org/temporary_website_test3/"
