#!/bin/bash

# Detect whether this is OpenWrt 25+ by probing feeds.conf.default for the
# "video" feed line, which only ships in OpenWrt 25+.
IS_OPENWRT_25=0
if [ -f friendlywrt/feeds.conf.default ] \
   && grep -qE '^[[:space:]]*src-git[[:space:]]+video[[:space:]]+https' friendlywrt/feeds.conf.default; then
    IS_OPENWRT_25=1
fi
echo "add_packages.sh: IS_OPENWRT_25=${IS_OPENWRT_25}"

# {{ Add luci-app-diskman
(cd friendlywrt && {
    mkdir -p package/luci-app-diskman
    if [ "${IS_OPENWRT_25}" = "1" ]; then
        wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O package/luci-app-diskman/Makefile
    else
        wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
    fi
    mkdir -p package/parted
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile
})
cat >> configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
EOL
# }}

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
APPEND_TEXT="$(mktemp -t appendtext.XXXXXX)"
trap 'rm -f "$APPEND_TEXT"' EXIT
cat > "$APPEND_TEXT" <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e "/boardname=/r $APPEND_TEXT" friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}
