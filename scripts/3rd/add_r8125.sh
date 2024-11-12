#!/bin/bash
set -eu
top_path=$(pwd)
pushd kernel
kernel_ver=`make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 kernelrelease`
popd
modules_dir=$(readlink -f ./out/output_*_kmodules/lib/modules/${kernel_ver})
[ -d ${modules_dir} ] || {
	echo "please build kernel first."
	exit 1
}

# fs overlay
config_dir="${top_path}/r8125-3rd/etc/modules.d/"
mkdir ${config_dir} -p

# build kernel driver
git clone https://github.com/zeroday0619/r8125 -b main
(cd r8125 && {
	export PATH=/opt/FriendlyARM/toolchain/11.3-aarch64:$PATH
	make CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 -C ${top_path}/kernel M=$(pwd)
	cp *.ko ${modules_dir}/ -afv
})

# load module on boot
echo "r8125" > ${config_dir}/10-r8125

# add overlay to rootfs
if ! grep -q r8125-3rd .current_config.mk; then
	echo "FRIENDLYWRT_FILES+=(r8125-3rd)" >> .current_config.mk
fi
