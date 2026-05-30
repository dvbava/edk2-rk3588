#!/bin/bash

# Update the local repository and submodules on the host machine
git pull
git submodule update --init --recursive --depth 1 --jobs 4

# Remove old build outputs from the local directory
rm -f orangepi-5-pro_NOR_FLASH.img
rm -f orangepi-5-pro_RAWEDK2.img

# Run the build inside the container using the mounted local files
docker run --rm -it --network host -v "$(pwd)":/repo edk2-rk3588:latest bash -lc "
cd /repo && \
git clean -xdf --exclude=misc/rkbin --exclude=misc/toolchain && \
sed -i 's/\r$//' build.sh configs/*.conf misc/rkbin/RKBOOT/*.ini misc/rkbin/RKTRUST/*.ini misc/extractbl31.py && \
./build.sh -d orangepi-5-pro -r RELEASE && \
git branch --show-current
"
