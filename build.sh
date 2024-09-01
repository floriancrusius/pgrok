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

        output_name="${binary_var}_${target}"
        
        # Add .exe extension for Windows binaries
        if [[ $target == windows* ]]; then
            output_name="${output_name}.exe"
        fi

        CGO_ENABLED=0 GOOS=${target%_*} GOARCH=${target#*_} go build -buildvcs=false -ldflags "${ldflags_var}" -o dist/bin/${output_name} ${main_var}

        echo "Archiving ${binary_var}_${target}"

        if [[ $target == windows* ]]; then
          zip dist/archive/${output_name}.zip dist/bin/${output_name}
        else 
          tar -czf dist/archive/${output_name}.tar.gz dist/bin/${output_name}
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
