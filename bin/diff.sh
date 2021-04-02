#!/usr/bin/env bash
. bin/common.sh

diff() {
  local pkg=$1
  if diff $pkg; then
    exit 1
  fi
}

for_each diff