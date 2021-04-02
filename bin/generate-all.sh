#!/usr/bin/env bash
. bin/common.sh

generate_client() {
  local pkg=$1
  if diff $pkg; then
    echo "Generating newer client: $pkg-$type"
    bin/generate-client.sh $pkg
  fi
}

for_each generate_client
