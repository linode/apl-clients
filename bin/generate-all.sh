#!/usr/bin/env bash
. bin/common.sh

generate_client() {
  if ! unpublished_exists $1 $2; then
    local pkg="@linode/$1-client-fetch@$2"
    echo "Generating newer package: $pkg"
    bin/generate-client.sh $1 $2
  fi
}

generate_grpc_client() {
  if ! unpublished_grpc_exists $1 $2; then
    local pkg="@linode/$1-client-grpc@$2"
    echo "Generating newer package: $pkg"
    bin/generate-grpc-client.sh $1 $2
  fi
}

for_each generate_client
for_each_grpc generate_grpc_client
