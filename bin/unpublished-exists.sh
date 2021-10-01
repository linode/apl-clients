#!/usr/bin/env bash
. bin/common.sh

check_exit() {
  if unpublished_exists $1 $2; then
    local pkg="@redkubes/$1-client-node@$2"
    echo "Unpublished package found: $pkg"
    exit 0
  fi
  exit 1
}

for_each check_exit