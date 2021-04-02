#!/usr/bin/env bash
. bin/common.sh

differ() {
  local pkg=$1
  if diff $pkg; then
    exit 1
  fi
}

for_each differ