del orangepi-5-pro_NOR_FLASH.img
del orangepi-5-pro_RAWEDK2.img

docker run --rm -it -v D:\codebase\edk2-rk3588:/output edk2-rk3588:latest bash -lc `
"git clone https://github.com/dvbava/edk2-rk3588.git /repo && `
cd /repo && `
git submodule update --init --recursive --depth 1 --jobs 4 && `
sed -i 's/\r$//' build.sh configs/*.conf misc/rkbin/RKBOOT/*.ini misc/rkbin/RKTRUST/*.ini misc/extractbl31.py && `
./build.sh -d orangepi-5-pro -r RELEASE && `
git status && `
cp /repo/*.img /output/"
