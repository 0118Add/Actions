#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

echo "开始 DIY2 配置……"
echo "========================="

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}
function drop_package(){
    find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}
function merge_feed(){
    if [ ! -d "feed/$1" ]; then
        echo >> feeds.conf.default
        echo "src-git $1 $2" >> feeds.conf.default
    fi
    ./scripts/feeds update $1
    ./scripts/feeds install -a -p $1
}
rm -rf package/custom; mkdir package/custom

# 更改主机名
sed -i "s/hostname='.*'/hostname='OpenWrt'/g" package/base-files/files/bin/config_generate

# 加入信息
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings
#sed -i "s/OPENWRT_RELEASE='*.*'/OPENWRT_RELEASE='OpenWrt R26.05.20'/g" package/lean/default-settings/files/zzz-default-settings
#sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION='R26.05.20'/g" package/lean/default-settings/files/zzz-default-settings

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/luci/bin/config_generate

# 设置密码为空（安装固件时无需密码登陆，然后自己修改想要的密码）
#sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings

# 替换内核
#sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' target/linux/armsr/Makefile

# 修改系统文件
#curl -fsSL https://raw.githubusercontent.com/0118Add/s9xxx-actions/main/patch/flippy_index.htm > ./package/lean/autocore/files/arm/index.htm
#curl -fsSL https://raw.githubusercontent.com/0118Add/X86-Actions/main/general/lede.index.htm > ./package/lean/autocore/files/arm/index.htm
#patch -p1 < ${GITHUB_WORKSPACE}/patch/luci-admin-status-index-html.patch

# 替换文件
wget -O ./package/lean/default-settings/files/zzz-default-settings https://raw.githubusercontent.com/0118Add/OpenWrt-CI/main/x86/diy/x86_lede/zzz-default-settings

# 替换banner
#wget -O ./package/base-files/files/etc/banner https://raw.githubusercontent.com/0118Add/OpenWrt-CI/main/x86/diy/x86_lede/banner

# 修改概览里时间显示为中文数字
#sed -i 's/os.date()/os.date("%Y-%m-%d") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")/g' package/lean/autocore/files/arm/index.htm

# 修改连接数
sed -i 's/net.netfilter.nf_conntrack_max=.*/net.netfilter.nf_conntrack_max=65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
# 修正连接数
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# golang 1.26
rm -rf feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang

# 预编译 node
rm -rf feeds/packages/lang/node
git clone --depth=1 -b packages-24.10 https://github.com/sbwml/feeds_packages_lang_node-prebuilt feeds/packages/lang/node

# 添加旁路由防火墙
#echo "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> package/network/config/firewall/files/firewall.user
#echo "iptables -t nat -I POSTROUTING -j FULLCONENAT" >> package/network/config/firewall/files/firewall.user

# 添加额外软件包
rm -rf package/lean/automount
rm -rf feeds/packages/net/{chinadns-ng,dns2tcp,dns2socks,msd_lite,lucky,geoview,tcping,v2ray-geodata,sing-box,xray-core}
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/applications/luci-app-lucky
rm -rf feeds/luci/applications/luci-app-filemanager
rm -rf feeds/luci/applications/luci-app-msd_lite
rm -rf feeds/luci/applications/luci-app-ssr-plus
#rm -rf feeds/luci/applications/luci-app-homeproxy
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-nikki
rm -rf feeds/packages/net/nikki
#rm -rf feeds/luci/applications/luci-app-unblockneteasemusic
rm -rf feeds/luci/applications/luci-app-tailscale
rm -rf feeds/luci/applications/luci-app-zerotier

#git clone https://github.com/sirpdboy/luci-app-ddns-go package/luci-app-ddns-go
#git clone https://github.com/jerrykuku/lua-maxminddb package/lua-maxminddb
#merge_package https://github.com/kiddin9/kwrt-packages kwrt-packages/luci-app-passwall
#git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
#git clone https://github.com/siropboy/luci-app-bypass package/luci-app-bypass
#git clone https://github.com/fw876/helloworld.git package/helloworld
#merge_package https://github.com/fw876/helloworld helloworld/luci-app-ssr-plus
#merge_package https://github.com/fw876/helloworld helloworld/lua-neturl
#merge_package https://github.com/fw876/helloworld helloworld/mosdns
#merge_package https://github.com/fw876/helloworld helloworld/dns2tcp
#merge_package https://github.com/fw876/helloworld helloworld/mihomo
#merge_package https://github.com/fw876/helloworld helloworld/tuic-client
#git clone https://github.com/Openwrt-Passwall/openwrt-passwall2 package/passwall2
git clone https://github.com/sirpdboy/luci-app-partexp package/luci-app-partexp
git clone https://github.com/sirpdboy/luci-app-lucky package/lucky
#git clone https://github.com/sbwml/luci-app-filemanager package/luci-app-filemanager
#rm -rf feeds/luci/themes/luci-theme-argon
#rm -rf feeds/luci/themes/luci-theme-design
#git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone -b dev --depth 1 https://github.com/vernesong/OpenClash package/openclash
git clone https://github.com/ophub/luci-app-amlogic package/amlogic
#git clone -b master https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic package/luci-app-unblockneteasemusic

#git clone --depth 1 -b master https://github.com/fun200/homeproxy_plus package/luci-app-homeproxy
#merge_package https://github.com/sbwml/openwrt_helloworld openwrt_helloworld/luci-app-homeproxy
sed -i "s/ImmortalWrt/OpenWrt/g" feeds/luci/applications/luci-app-homeproxy/po/zh_Hans/homeproxy.po
sed -i "s/ImmortalWrt proxy/OpenWrt proxy/g" feeds/luci/applications/luci-app-homeproxy/htdocs/luci-static/resources/view/homeproxy/{client.js,server.js}

git clone --depth=1 -b openwrt-25.12 https://github.com/immortalwrt/luci immortalwrt-luci
cp -rf immortalwrt-luci/applications/luci-app-msd_lite feeds/luci/applications/luci-app-msd_lite
ln -sf ../../../feeds/luci/applications/luci-app-msd_lite ./package/feeds/luci/luci-app-msd_lite
cp -rf immortalwrt-luci/applications/luci-app-filemanager feeds/luci/applications/luci-app-filemanager
ln -sf ../../../feeds/luci/applications/luci-app-filemanager ./package/feeds/luci/luci-app-filemanager
git clone --depth=1 -b openwrt-25.12 https://github.com/immortalwrt/packages immortalwrt-packages
cp -rf immortalwrt-packages/net/msd_lite feeds/packages/net/msd_lite
ln -sf ../../../feeds/packages/net/msd_lite ./package/feeds/packages/msd_lite
#cp -rf immortalwrt-packages/net/sing-box feeds/packages/net/sing-box
#ln -sf ../../../feeds/packages/net/sing-box ./package/feeds/packages/sing-box

# Dockerman
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://github.com/sbwml/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
sed -i 's/"admin/"admin\/services/g' feeds/luci/applications/luci-app-dockerman/root/usr/share/luci/menu.d/luci-app-dockerman.json

# 修改插件名字（修改名字后不知道会不会对插件功能有影响，自己多测试）
#sed -i 's/广告屏蔽大师 Plus+/广告屏蔽/g' feeds/luci/applications/luci-app-adbyby-plus/po/zh-cn/adbyby.po
#sed -i 's/解除网易云音乐播放限制/音乐解锁/g' package/luci-app-unblockneteasemusic/luasrc/controller/unblockneteasemusic.lua
sed -i 's/解除网易云音乐播放限制/音乐解锁/g' feeds/luci/applications/luci-app-unblockneteasemusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json
#sed -i 's/Argon 主题设置/Argon设置/g' feeds/luci/applications/luci-app-argon-config/po/zh-cn/argon-config.po
#sed -i 's/Design 主题设置/Design设置/g' feeds/luci/applications/luci-app-design-config/po/zh-cn/design-config.po
#sed -i 's/一键分区扩容/分区扩容/g' package/luci-app-partexp/po/zh-cn/partexp.po
#sed -i 's/ShadowSocksR Plus+/SSR Plus+/g' package/custom/luci-app-ssr-plus/luasrc/controller/shadowsocksr.lua
#sed -i 's/Argon 主题设置/主题设置/g' feeds/luci/applications/luci-app-argon-config/po/zh-cn/argon-config.po
#sed -i 's/Frp 内网穿透/内网穿透/g' feeds/luci/applications/luci-app-frpc/po/zh-cn/frp.po
#sed -i 's/Docker CE 容器/Docker 容器/g' feeds/luci/applications/luci-app-docker/po/zh-cn/docker.po
#sed -i 's/WireGuard 状态/WiGd状态/g' feeds/luci/applications/luci-app-wireguard/po/zh-cn/wireguard.po
#sed -i 's/Turbo ACC 网络加速/网络加速/g' feeds/luci/applications/luci-app-turboacc/po/zh_Hans/turboacc.po

# luci-app-amlogic 晶晨宝盒
#sed -i "s|https.*/s9xxx-openwrt|https://github.com/0118Add/s9xxx-actions|g" package/amlogic/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|opt/kernel|https://github.com/0118Add/kernel|g" package/amlogic/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|s9xxx_lede|g" package/amlogic/luci-app-amlogic/root/etc/config/amlogic

# 调整 Dockerman 到 服务 菜单
#sed -i 's/"admin",/"admin","services",/g' ./feeds/luci/applications/luci-app-dockerman/luasrc/controller/*.lua
#sed -i 's/"admin/"admin\/services/g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/*.lua
#sed -i 's/"admin/"admin\/services/g' ./feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/*.lua
#sed -i 's/"admin/"admin\/services/g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/*.htm
#sed -i 's/"admin/"admin\/services/g' ./feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/cbi/*.htm

# 修改系统文件
#curl -fsSL https://raw.githubusercontent.com/0118Add/Openwrt-CI/main/x86/diy/x86_lede/10_system.js > ./feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
curl -fsSL https://raw.githubusercontent.com/0118Add/X86_64-Test/main/general/25_storage.js > ./feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/25_storage.js
#curl -fsSL https://raw.githubusercontent.com/0118Add/Cloudbuild/main/patches/29_ports.js > ./feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/29_ports.js
#curl -fsSL https://raw.githubusercontent.com/0118Add/X86_64-Test/main/general/30_network.js > ./feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/30_network.js
curl -fsSL https://raw.githubusercontent.com/0118Add/Actions/main/patch/release-os > package/base-files/files/etc/os-release


echo "🚀 拉取 luci-app-honk 并预放 x86_64 二进制核心"
set -e

# 1. 分段拼接防截断变量
GH_HOST="https://github.com"
LUCI_REPO_URL="${GH_HOST}/QiuSimons/luci-app-honk.git"
CORE_RELEASES_URL="${GH_HOST}/daeuniverse/honk/releases"
TARGET_ARCH="aarch64-unknown-linux-musl"

HONK_REPO="package/luci-app-honk"
HONK_DIR="${HONK_REPO}/honk"
HONK_BIN="${HONK_DIR}/files/honk-core.bin"

# 2. 克隆源码
echo "🚀 正在克隆: ${LUCI_REPO_URL}"
rm -rf "$HONK_REPO"
git clone --depth=1 "$LUCI_REPO_URL" "$HONK_REPO"

# 3. 直接从 Releases 网页自动获取最新版本号并拼接官方直链（免 API 限流）
echo "🔍 正在自动获取 honk-core 最新版本号..."
LATEST_TAG=$(curl -fsSL "$CORE_RELEASES_URL" | \
    grep -oE '/daeuniverse/honk/releases/tag/v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?' | \
    head -n1 | awk -F'/' '{print $NF}')

[ -n "$LATEST_TAG" ] || { echo "❌ 错误：未能自动获取到最新版本号！"; exit 1; }
echo "📌 自动获取到最新版本: ${LATEST_TAG}"

DOWNLOAD_URL="${CORE_RELEASES_URL}/download/${LATEST_TAG}/honk-core-${LATEST_TAG}-${TARGET_ARCH}-full.tar.gz"
echo "📥 最终下载地址: $DOWNLOAD_URL"

# 5. 下载、解压并预放二进制文件
curl -fsSL --retry 5 --retry-delay 2 -o /tmp/honk-core.tar.gz "$DOWNLOAD_URL"
rm -rf /tmp/honkpkg && mkdir -p /tmp/honkpkg
tar -xzf /tmp/honk-core.tar.gz -C /tmp/honkpkg

CORE_FILE=$(find /tmp/honkpkg -type f -name "honk-core*" ! -name "*.tar.gz" -print -quit)
[ -n "$CORE_FILE" ] || { echo "❌ 压缩包内未找到 honk-core 二进制文件！"; exit 1; }

mkdir -p "${HONK_DIR}/files"
cp -f "$CORE_FILE" "$HONK_BIN"
chmod +x "$HONK_BIN"
rm -rf /tmp/honk-core.tar.gz /tmp/honkpkg

echo "✅ honk-core.bin 预放成功！文件大小: $(du -h "$HONK_BIN" | cut -f1)"

# 6. 修正 Makefile 中可能存在的大写 SKIP 占位符
find "$HONK_REPO" -type f -name "Makefile" -exec sed -i -E 's/^([[:space:]]*PKG_(HASH|MIRROR_HASH)[[:space:]]*:?=[[:space:]]*)SKIP[[:space:]]*$/\1skip/' {} +

./scripts/feeds update -a
./scripts/feeds install -a
