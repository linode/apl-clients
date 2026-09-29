#!/usr/bin/env bash
set -e
[ -n "$DEBUG" ] && set -x

pushd vendors/openapi >/dev/null
clients=$(find . -type f -name '*.json')
popd >/dev/null

unpublished_exists() {
  local pkg=$1
  local version=$2
  if [ -n "$(npm info "@linode/$pkg-client-fetch@$version")" ]; then
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

pushd vendors/proto >/dev/null
grpc_clients=$(find . -mindepth 2 -maxdepth 2 -type d)
popd >/dev/null

unpublished_grpc_exists() {
  local pkg=$1
  local version=$2
  if [ -n "$(npm info "@linode/$pkg-client-grpc@$version")" ]; then
    return 0
  fi
  return 1
}

for_each_grpc() {
  executable=$1
  shift
  for each in $grpc_clients; do
    local dir=${each:2}
    local pkg=${dir%%/*}
    local version=${dir#*/}
    $executable $pkg $version
  done
}
