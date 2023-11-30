#!/bin/bash

set -euo pipefail

# Run before hooks
make deps
make assets

rm -rf dist/*

mkdir -p dist
mkdir -p dist/bin
mkdir -p dist/archive
# Define build function
build() {
    ldflags_var=$1
    main_var=$2
    binary_var=$3
    targets_var=("${@:4}")

    for target in "${targets_var[@]}"; do
        echo "Building for $target"

        output_name="${binary_var}"
        
        # Add .exe extension for Windows binaries
        if [[ $target == windows* ]]; then
            output_name="${output_name}.exe"
        fi

        CGO_ENABLED=0 GOOS=${target%_*} GOARCH=${target#*_} go build -ldflags "${ldflags_var}" -o dist/bin/${binary_var}_${target}/${output_name} ${main_var}

        echo "Archiving ${binary_var}_${target}"

        case ${target#*_} in
          arm64)
            arch="ARM";;
          amd64)
            arch="x64";;
          386)
            arch="x86";;
          *)
            arch="${target#*_}";;
        esac

        case ${target%_*} in
          windows)
            os="windows";;
          darwin)
            os="macOS";;
          linux)
            os="linux";;
          android)
            os="android";;
          *)
            os="${target%_*}";;
        esac

        if [[ $target == windows* ]]; then
          cd dist/bin/${binary_var}_${target}/
          zip ../../archive/${binary_var}_${os}_${arch}.zip *
          cd ../../../
        else 
          cd dist/bin/${binary_var}_${target}/
          tar -czf ../../archive/${binary_var}_${os}_${arch}.tar.gz *
          cd ../../../
        fi

    done
}

# Build pgrok
build "-s -w" "./cmd/pgrok" "pgrok" "darwin_amd64" "darwin_arm64" "windows_amd64" "windows_386" "linux_amd64" "linux_arm64" "linux_386" "android_arm64"

# Build pgrokd
build "-s -w" "./cmd/pgrokd" "pgrokd" "darwin_amd64" "darwin_arm64" "windows_amd64" "windows_386" "linux_amd64" "linux_arm64" "linux_386"

# Create checksums
echo "Creating checksums"
rm -f dist/checksums.txt
for binary in dist/bin/pgrok dist/bin/pgrokd; do
    sha256sum ${binary}_* > dist/checksums.txt
done

echo "Build script completed."
