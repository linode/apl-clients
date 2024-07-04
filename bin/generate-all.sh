#!/usr/bin/env bash
. bin/common.sh

generate_client() {
  if ! unpublished_exists $1 $2; then
    local pkg="@linode/$1-client-node@$2"
    echo "Generating newer package: $pkg"
    bin/generate-client.sh $1 $2
  fi
}

for_each generate_client
