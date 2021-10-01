#!/usr/bin/env bash
set -e
[ -n "$DEBUG" ] && set -x

pushd vendors/openapi >/dev/null
clients=$(find . -type f -name '*.json')
popd >/dev/null

unpublished_exists() {
  local pkg=$1
  local version=$2
  if [ -z "$(npm info "@redkubes/$pkg-client-node@$version")" ]; then
    return 0
  fi
  return 1
}

for_each() {
  executable=$1
  shift
  for each in $clients; do
    local file=${each:2}
    local pkg=${file%%/*}
    local remainder=${file##*/}
    local version=${remainder%.*}
    $executable $pkg $version
  done
}