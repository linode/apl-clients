#!/usr/bin/env bash
. bin/common.sh

found=0

check_exit() {
  if unpublished_exists $1 $2; then
    local pkg="@linode/$1-client-fetch@$2"
    echo "Unpublished package found: $pkg"
    found=1
  fi
}

check_exit_grpc() {
  if unpublished_grpc_exists $1 $2; then
    local pkg="@linode/$1-client-grpc@$2"
    echo "Unpublished package found: $pkg"
    found=1
  fi
}

for_each check_exit
for_each_grpc check_exit_grpc

if [ "$found" -eq 1 ]; then
  exit 0
fi
exit 1
