#!/usr/bin/env sh

for each in "harbor/node" "keycloak/node" "gitea/node"; do
  pkg=${each%%/*}
  type=${each##*/}
  echo "Publishing newer client: $pkg-$type"
  cd vendors/client/$pkg/$type
  npm publish --access public
  cd -
done
exit 0