#!/bin/sh

IN_OTA_IMAGE=$HOME/raspberrypi/omni_rpi4-ota-eng.maxl.$ROM_BUILDTYPE.zip
DATE=`date +%Y%m%d`
OUT_OTA_BASENAME=omni-13-$DATE-rpi4-$ROM_BUILDTYPE.zip
OUT_IMAGE_DIR=$HOME/raspberrypi/images/
OUT_OTA_IMAGE=$OUT_IMAGE_DIR/$OUT_OTA_BASENAME
DO_UPLOAD=0
DO_STAGING=0
DL_SERVER_USER=omnirom
DL_SERVER_IP=95.216.102.24
DL_SERVER_ROOT=dl.omnirom.org
KEYFILE=/home/maxl/.ssh/omni

if [ -z $ROM_BUILDTYPE ]; then
    echo "missing ROM_BUILDTYPE"
    exit 0
fi

options=$(getopt -o hus -- "$@")
[ $? -eq 0 ] || { 
    echo "Incorrect options provided"
    exit 1
}

eval set -- "$options"
while true; do
    case "$1" in
    -u)
        DO_UPLOAD=1
        shift
        ;;
    -s)
        DO_STAGING=1
        shift
        ;;
    -h)
        echo "-u"
        echo "upload"
        echo "-s"
        echo "upload to staging"
        exit 0
        ;;
    --)
        shift
        break
        ;;
    esac
done

if  [ ! -f $IN_OTA_IMAGE ]; then
    echo "no $IN_OTA_IMAGE"
    exit 0
fi

cp $IN_OTA_IMAGE $OUT_OTA_IMAGE
cd $OUT_IMAGE_DIR
md5sum $OUT_OTA_BASENAME > $OUT_OTA_BASENAME.md5sum

check_remote_dir () {
    echo check_remote_dir $1
    ssh -i $KEYFILE $DL_SERVER_USER@$DL_SERVER_IP "mkdir -p $DL_SERVER_ROOT/$1" 2>/dev/null >/dev/null
}

if  [ $DO_UPLOAD -eq 1 ]; then
    echo "uploading"
    if  [ ! -f $OUT_OTA_BASENAME ]; then
        echo "no $OUT_OTA_BASENAME"
        exit 0
    fi
    if  [ ! -f $OUT_OTA_BASENAME.md5sum ]; then
        echo "no $OUT_OTA_BASENAME.md5sum"
        exit 0
    fi
    if [ $DO_STAGING -eq 1 ]; then
        UPLOAD_DIR=tmp/rpi4/staging/
    else
        UPLOAD_DIR=tmp/rpi4/
    fi
    echo "uploading to $UPLOAD_DIR"
    
    check_remote_dir $UPLOAD_DIR

    rsync -au -v --progress  $OUT_OTA_BASENAME -e "ssh -i $KEYFILE" $DL_SERVER_USER@$DL_SERVER_IP:$DL_SERVER_ROOT/$UPLOAD_DIR
    rsync -au -v --progress  $OUT_OTA_BASENAME.md5sum -e "ssh -i $KEYFILE" $DL_SERVER_USER@$DL_SERVER_IP:$DL_SERVER_ROOT/$UPLOAD_DIR
fi

#rm $IN_OTA_IMAGE