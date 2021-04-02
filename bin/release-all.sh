#!/usr/bin/env bash
. bin/common.sh

release() {
  local pkg=$1
  if diff $pkg; then
    local type=$2
    echo "Publishing newer client: $pkg-$type"
    cd vendors/client/$pkg/$type
    npm publish --access public
    cd -
  fi
}

for_each release
