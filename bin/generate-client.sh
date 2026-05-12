#!/usr/bin/env bash

set -e

org=linode
repo='ssh://git@github.com/linode/apl-clients.git'

vendor="$1"
type="fetch"
version="$2"
openapi_doc="vendors/openapi/$vendor/$version.json"
inputfile="tmp/openapi.json"
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

apply_patch() {
    mkdir -p tmp
    if [ "$vendor" == "gitea" ]; then
        # Rename from renderMarkdownRaw as "raw" suffix is used by generator and causes conflicts
        # https://github.com/OpenAPITools/openapi-generator/issues/11827
        jq '.paths."/markdown/raw".post.operationId = "renderRawMarkdown"' $openapi_doc > $inputfile
    elif [ "$vendor" == "keycloak" ]; then
        # Remove deprecated endpoint which causes errors
        jq 'del(.paths."/admin/realms/{realm}/testSMTPConnection")' $openapi_doc > $inputfile
    else
        cp "$openapi_doc" "$inputfile"
    fi
}

generate_client() {
    echo "Generating client code from openapi specification $openapi_doc..."
    rm -rf $target_dir >/dev/null
    docker run --rm -v $PWD:/local \
    --user 1001:1001 \
    openapitools/openapi-generator-cli generate \
    -i /local/$inputfile \
    -o /local/$target_dir \
    -g typescript-fetch \
    --additional-properties supportsES6=true,npmName=$target_npm_name,prefixParameterInterfaces=true
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
apply_patch
generate_client 
set_package_json
build_npm_package

echo "The client code has been generated at $target_dir/ directory"
