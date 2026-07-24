#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/coolsnowwolf/lede / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Set default IP address
default_ip="192.168.1.1"
ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
# Modify default IP if an argument is provided and it matches the IP format
[[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]] && {
    echo "Modify default IP address to: ${1}"
    sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" package/base-files/*/bin/config_generate
}

# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
# sed -i 's/luci-theme-bootstrap/luci-theme-material/g' ./feeds/luci/collections/luci/Makefile

# Add autocore support for armsr-armv8
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armsr/g' package/lean/autocore/Makefile

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings
echo "DISTRIB_SOURCEREPO='github.com/coolsnowwolf/lede'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='lede'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEBRANCH='master'" >>package/base-files/files/etc/openwrt_release

# Set ccache
# Remove existing ccache settings
sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config
# Apply new ccache configuration
if [[ "${2}" == "true" ]]; then
    echo "CONFIG_DEVEL=y" >>.config
    echo "CONFIG_CCACHE=y" >>.config
    echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >>.config
else
    echo '# CONFIG_DEVEL is not set' >>.config
    echo "# CONFIG_CCACHE is not set" >>.config
    echo 'CONFIG_CCACHE_DIR=""' >>.config
fi
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone -b main https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------

# Dockerman(Docker管理面板)
git clone https://github.com/lisaac/luci-app-dockerman package/luci-app-dockerman

# OpenClash
git clone https://github.com/vernesong/OpenClash package/luci-app-openclash

# ttyd 网页终端
git clone https://github.com/lisaac/luci-app-ttyd package/luci-app-ttyd

# 解锁网易云音乐
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/luci-app-unblockneteasemusic

# Samba4 文件共享
git clone https://github.com/lisaac/luci-app-samba4 package/luci-app-samba4

# 分区扩容
git clone https://github.com/lisaac/luci-app-partexp package/luci-app-partexp

# quickfile 文件管理器
git clone https://github.com/lisaac/luci-app-quickfile package/luci-app-quickfile

# USB打印机服务
git clone https://github.com/lisaac/luci-app-p910nd package/luci-app-p910nd

# 磁盘管理
git clone https://github.com/lisaac/luci-app-diskman package/luci-app-diskman

# Aria2下载工具
git clone https://github.com/lisaac/luci-app-aria2 package/luci-app-aria2

# AP‑Modem 访问光猫AP
git clone https://github.com/lisaac/luci-app-ap-modem package/luci-app-ap-modem

# Alist网盘管理
git clone https://github.com/sbwml/luci-app-alist package/luci-app-alist

# FRPC内网穿透客户端
git clone https://github.com/kuoruan/luci-app-frpc package/luci-app-frpc

# ZeroTier异地组网
git clone https://github.com/lisaac/luci-app-zerotier package/luci-app-zerotier

# DDNS动态域名
git clone https://github.com/lisaac/luci-app-ddns package/luci-app-ddns

# SmartDNS域名加速解析
git clone https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns

# Argon美化主题（成熟稳定）
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# iStore 软件中心（仅商店面板，不整套UI）
git clone https://github.com/linkease/istore package/istore
cp -r package/istore/luci/luci-app-store package/luci-app-store
