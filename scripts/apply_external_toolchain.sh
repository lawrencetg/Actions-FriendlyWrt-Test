#!/bin/bash

case $1 in
21.02)
    wget https://raw.githubusercontent.com/friendlyarm/openwrt-toolchain/master/openwrt-toolchain-21.02.5-rockchip-armv8_gcc-11.2.0_musl.Linux-x86_64.tar.xz -O ~/toolchain.tar.xz
    ;;
22.03)
    wget https://raw.githubusercontent.com/friendlyarm/openwrt-toolchain/master/openwrt-toolchain-22.03.2-rockchip-armv8_gcc-11.2.0_musl.Linux-x86_64.tar.xz -O ~/toolchain.tar.xz
    ;;
*)
    echo "unknow version"
    exit 1
esac

mkdir -p ~/openwrt
tar xvjf ~/toolchain.tar.xz --strip-components 1 -C ~/openwrt
(cd ~/openwrt && mv toolchain* toolchain)
toolchain_root=$(readlink -f ~/openwrt/toolchain)

cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_EXTERNAL_TOOLCHAIN=y
CONFIG_EXTERNAL_TOOLCHAIN_LIBC_USE_MUSL=y
CONFIG_TARGET_NAME="aarch64-openwrt-linux"
CONFIG_TOOLCHAIN_PREFIX="aarch64-openwrt-linux-musl-"
CONFIG_TOOLCHAIN_ROOT="${toolchain_root}"
CONFIG_TOOLCHAIN_BIN_PATH="./bin ./usr/bin"
EOL

