#!/usr/bin/env bash
. bin/common.sh

release() {
  if ! unpublished_exists $1 $2; then
    local pkg="@redkubes/$1-client-node@$2"
    echo "Publishing newer package: $pkg"
    cd vendors/client/$1/$2
    npm publish --access public
    cd -
  fi
}

for_each release
