#!/usr/bin/env bash

set -e

org=linode
repo='ssh://git@github.com/linode/apl-clients.git'

vendor="$1"
type="grpc"
version="$2"
proto_dir="vendors/proto/$vendor/$version"
registry="https://npm.pkg.github.com/"
target_dir="vendors/client/$vendor-grpc/$version"
target_package_json="$target_dir/package.json"
target_npm_name="@$org/$vendor-client-$type"

grpc_js_version=$(node -p "require('./package.json').devDependencies['@grpc/grpc-js']")
bufbuild_version=$(node -p "require('./package.json').devDependencies['@bufbuild/protobuf']")

validate() {
    if [ -z "$vendor" ]; then
        printf 'No vendor argument supplied.\nUsage:\n\t./bin/generate-grpc-client.sh <vendor-name> <version>\n'
        exit 1
    fi

    if [ ! -d "$proto_dir" ] || [ -z "$(find "$proto_dir" -maxdepth 1 -name '*.proto')" ]; then
        echo "No .proto file found in $proto_dir."
        exit 1
    fi
}

generate_client() {
    echo "Generating gRPC client code from $proto_dir..."
    rm -rf "$target_dir" >/dev/null
    mkdir -p "$target_dir"
    node_modules/.bin/grpc_tools_node_protoc \
        --plugin=protoc-gen-ts_proto=./node_modules/.bin/protoc-gen-ts_proto \
        --ts_proto_out="$target_dir" \
        --ts_proto_opt=outputServices=grpc-js,esModuleInterop=true,env=node,outputJsonMethods=false,outputClientImpl=true \
        -I "$proto_dir" \
        "$proto_dir"/*.proto
}

write_package_json() {
    echo "Writing $target_package_json..."
    local proto_file
    proto_file=$(basename "$(find "$proto_dir" -maxdepth 1 -name '*.proto' | head -1)" .proto)
    jq -n \
        --arg name "$target_npm_name" \
        --arg version "$version" \
        --arg main "$proto_file.js" \
        --arg types "$proto_file.d.ts" \
        --arg grpcJsVersion "$grpc_js_version" \
        --arg bufbuildVersion "$bufbuild_version" \
        --arg repoType 'git' \
        --arg repoUrl "$repo" \
        --arg repoDirectory "packages/vendors/$vendor-grpc" \
        --arg registry "$registry" \
        '{
          name: $name,
          version: $version,
          main: $main,
          types: $types,
          files: ["*.js", "*.d.ts"],
          scripts: { build: "tsc" },
          dependencies: {
            "@bufbuild/protobuf": $bufbuildVersion
          },
          peerDependencies: {
            "@grpc/grpc-js": $grpcJsVersion
          },
          devDependencies: {
            "@grpc/grpc-js": $grpcJsVersion,
            typescript: "*"
          },
          repository: { type: $repoType, url: $repoUrl, directory: $repoDirectory },
          publishConfig: { registry: $registry }
        }' > "$target_package_json"
}

write_tsconfig() {
    cat > "$target_dir/tsconfig.json" <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "declaration": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "strict": false
  },
  "include": ["*.ts"]
}
EOF
}

build_npm_package() {
    echo "Building $target_npm_name npm package"
    cd "$target_dir"
    npm install && npm run build
    cd - >/dev/null
}

validate
generate_client
write_package_json
write_tsconfig
build_npm_package

echo "The gRPC client code has been generated at $target_dir/ directory"
