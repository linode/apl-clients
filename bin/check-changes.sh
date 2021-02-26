#!/usr/bin/env sh
set -x
for each in "harbor/node" "keycloak/node" "gitea/node"; do
  pkg=${each%%/*}
  if git --no-pager log -1 --stat --oneline --name-only | grep "vendors/openapi/$pkg.json" >/dev/null; then
    exit 0
  fi
done
echo "No changes found, skipping!"
exit 1