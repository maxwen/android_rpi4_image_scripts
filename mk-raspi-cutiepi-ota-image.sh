#!/bin/sh

if [ -z $OUT_DIR ]; then
    OUT_DIR=`pwd`/out
fi

CDIR=`pwd`
IN_OTA_IMAGE=$OUT_DIR/target/product/rpi4/omni_rpi4-ota-eng.maxl.zip
OUT_OTA_IMAGE=$HOME/raspberrypi/`basename $IN_OTA_IMAGE`
IN_BOOT_IMAGE=$HOME/raspberrypi/boot-cutiepi.img
IN_OTA_FILES=$HOME/raspberrypi/ota-files

if  [ ! -f "$IN_BOOT_IMAGE" ]; then
    echo "not boot.img"
    exit 0
fi

if  [ ! -f "$IN_OTA_IMAGE" ]; then
    echo "no ota image"
    exit 0
fi

if  [ ! -d "$IN_OTA_FILES" ]; then
    echo "no ota files"
    exit 0
fi

if [ -d /tmp/ota ]; then
    rm -fr /tmp/ota/
fi
mkdir /tmp/ota/
cp $IN_BOOT_IMAGE /tmp/ota/boot.img
mkdir /tmp/ota/scripts/
cp $IN_OTA_FILES/backup.sh /tmp/ota/scripts/
cp $IN_OTA_FILES/restore.sh /tmp/ota/scripts/
mkdir -p /tmp/ota/META-INF/com/google/android/
cp $IN_OTA_FILES/updater-script /tmp/ota/META-INF/com/google/android/updater-script
cp $IN_OTA_FILES/update-binary /tmp/ota/META-INF/com/google/android/update-binary

cd /tmp/ota/
cp $IN_OTA_IMAGE $OUT_OTA_IMAGE
zip -r $OUT_OTA_IMAGE boot.img
zip -r $OUT_OTA_IMAGE scripts
zip -r $OUT_OTA_IMAGE META-INF/com/google/android/updater-script
zip -r $OUT_OTA_IMAGE META-INF/com/google/android/update-binary
cd $CDIR
exit 1
