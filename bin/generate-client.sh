#!/usr/bin/env bash

set -e

org=redkubes
repo='ssh://git@github.com/redkubes/otomi-clients.git'

vendor="$1"
type="node"
version="$2"
openapi_doc="vendors/openapi/$vendor/$version.json"
registry="https://npm.pkg.github.com/"
target_dir="vendors/client/$vendor/$version"
target_package_json="$target_dir/package.json"
target_npm_name="@$org/$vendor-client-$type"

validate() {
    if [ -z "$vendor" ]; then
        printf 'No vendor argument supplied.\nUsage:\n\t./bin/generate-client.sh <vendor-name>\n'
        exit 1
    fi

    if [ ! -f "$openapi_doc" ]; then
        echo "The file $openapi_doc does not exist."
        exit 1
    fi

}

generate_client() {
    echo "Generating client code from openapi specification $openapi_doc..."
    rm -rf $target_dir >/dev/null
    docker run --rm -v $PWD:/local \
    --user 1001:1001 \
    openapitools/openapi-generator-cli generate \
    -i /local/$openapi_doc \
    -o /local/$target_dir \
    -g typescript-node \
    --additional-properties supportsES6=true,npmName=$target_npm_name
}

 set_package_json() {
    echo "Updating  $target_package_json file..."

    jq \
    --arg type 'git' \
    --arg url $repo \
    --arg directory "packages/vendors/$vendor" \
    --arg registry $registry \
    '. + {"repository": {"type": $type, "url": $url, "directory": $directory}, "publishConfig": {"registry": $registry}}' \
    $target_package_json > /tmp/pkg.json
    mv /tmp/pkg.json $target_package_json
}

build_npm_package() {
    echo "Building $target_npm_name npm package"
    cd $target_dir
    npm install && npm run build
    cd $DIR
}

validate
generate_client 
set_package_json
build_npm_package

echo "The client code has been generated at $target_dir/ directory"
