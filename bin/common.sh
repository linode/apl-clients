#!/usr/bin/env bash
set -e
[ -n "$DEBUG" ] && set -x

clients=('harbor/node' 'keycloak/node' 'gitea/node')

diff() {
  local pkg=$1
  if git --no-pager log -1 --stat --oneline --name-only | grep "vendors/openapi/$pkg.json" >/dev/null; then
    return 0
  fi
  return 1
}

function for_each() {
  executable=$1
  shift
  for each in "${clients[@]}"; do
    pkg=${each%%/*}
    type=${each##*/}
    $executable $pkg $type
  done
}