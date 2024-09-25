#We are updating OpenWRT on the Aqara ZHWG11LM gateway from version 21 to 22.03.6
#!/bin/sh
set -e
cd /tmp
echo "Starting the procedure for updating OpenWRT from version 21 to 22.03.6"
sleep 2
wget https://openlumi.github.io/releases/22.03.6/targets/imx/cortexa7/u-boot-xiaomi_dgnwg05lm/u-boot.imx -O /tmp/u-boot.imx
wget https://openlumi.github.io/releases/22.03.6/targets/cortexa7/openlumi-22.03.6-imx-cortexa7-imx6ull-aqara-zhwg11lm.dtb -O /tmp/openlumi-22.03.6-imx-cortexa7-imx6ull-aqara-zhwg11lm.dtb
wget https://openlumi.github.io/releases/22.03.6/targets/cortexa7/openlumi-22.03.6-imx-cortexa7-aqara_zhwg11lm-squashfs-sysupgrade.bin -O /tmp/openlumi-22.03.6-imx-cortexa7-aqara_zhwg11lm-squashfs-sysupgrade.bin
echo "Done. The files are downloaded to the tmp folder"
sleep 2
echo "Starting replace model marks to allow upgrade with new files for update OpenWRT 21"
sed -i 's/gw5/aqara,zhwg11lm/' /lib/upgrade/platform.sh
sed -i 's/Wandboard i.MX6 Dual Lite Board/Aqara Gateway ZHWG11LM/' /lib/imx6.sh
sed -i 's/name="wandboard"/name="aqara,zhwg11lm"/' /lib/imx6.sh
echo 'aqara,zhwg11lm' > /tmp/sysinfo/board_name
echo 'Aqara Gateway ZHWG11LM' > /tmp/sysinfo/model
sed -i 's/"id": "[-a-z\.,]*"/"id": "aqara,zhwg11lm"/' /tmp/board.json
sed -i 's/board_name="$1"/board_name="${1\/,\/_}"/' /lib/upgrade/nand.sh
echo "Done replace"
sleep 2
echo "Starting write new uboot"
opkg update && opkg install kobs-ng
[ -f u-boot.imx ] && kobs-ng init -x -v --chip_0_device_path=/dev/mtd0 u-boot.imx
echo "Done write uboot"
sleep 2
echo "Starting write new dtb"
[ -f openlumi-22.03.6-imx-cortexa7-imx6ull-aqara-zhwg11lm.dtb ] && flash_erase /dev/mtd2 0 0 && nandwrite -p /dev/mtd2 -p openlumi-22.03.6-imx-cortexa7-imx6ull-aqara-zhwg11lm.dtb
echo "Firmware update to OpenWRT version 22.03.6 has been completed"
sleep 2
echo "Starting run sysupgrade in console"
[ -f openlumi-22.03.6-imx-cortexa7-aqara_zhwg11lm-squashfs-sysupgrade.bin ] && sysupgrade -v -n openlumi-22.03.6-imx-cortexa7-aqara_zhwg11lm-squashfs-sysupgrade.bin
