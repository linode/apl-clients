#!/usr/bin/env bash
. bin/common.sh

release() {
  if ! unpublished_exists $1 $2; then
    local pkg="@linode/$1-client-fetch@$2"
    echo "Publishing newer package: $pkg"
    cd vendors/client/$1/$2
    npm publish --access public
    cd -
  fi
}

release_grpc() {
  if ! unpublished_grpc_exists $1 $2; then
    local pkg="@linode/$1-client-grpc@$2"
    echo "Publishing newer package: $pkg"
    cd vendors/client/$1-grpc/$2
    npm publish --access public
    cd -
  fi
}

for_each release
for_each_grpc release_grpc
