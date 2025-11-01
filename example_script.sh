#!/bin/bash
# An example build script showing how to use the docker image to build a Bevy project, copy the output to a build directory, and notify the Steam Devkit Client for auto-upload.
# Intended to be copied into and ran from the root of your Bevy project.

if [ -n "$1" ]; then
    BINARY_NAME="$1"
else
    if ! command -v toml &> /dev/null; then
        echo "Error: toml-cli is not installed"
        echo "Please either:"
        echo "  - Pass the binary name as an argument: $0 <binary_name>"
        echo "  - Install toml-cli by running: cargo install toml-cli"
        exit 1
    fi
    BINARY_NAME=$(toml get Cargo.toml package.name --raw)
fi
if ! docker image inspect bevy_steamos >/dev/null 2>&1; then
    echo "Docker image 'bevy_steamos' not found. Building it..."
    docker build -t bevy_steamos https://raw.githubusercontent.com/paul-hansen/bevy_steamos_docker/main/Dockerfile
fi

docker run -v .:/usr/src/project bevy_steamos cargo build --release
cp "./target/release/$BINARY_NAME" "./build/$BINARY_NAME"
cp ./assets/* ./build/assets/

# Notify Steam Devkit Client for auto-upload
echo "Notifying Steam Devkit Client for auto-upload..."
curl -s -X POST http://127.0.0.1:32010/post_event \
  -H "Content-Type: application/json" \
  -d "{\"type\": \"build\", \"status\": \"success\", \"name\": \"$BINARY_NAME\"}" \
  -o /dev/null -w "%{http_code}" | grep -q "200" || echo -e "\033[33mWarning\033[0m: Failed to notify Steam Devkit Client (is it running?)"

echo ""
echo -e "\033[32mSuccess\033[0m: Build complete!"
