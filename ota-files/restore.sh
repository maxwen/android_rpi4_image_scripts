#!/sbin/sh

echo "run restore"

enable_property()
{
  sed -i "s/^#$1/$1/" $2
}

disable_property()
{
  sed -i "s/^$1/#$1/" $2
}

if [ -f "/tmp/is_recovery_image" ]; then
# first flash from recovery image nothing to restore
# just set boot device overlay

  echo "initial flash - nothing to restore"

  if [ -f "/tmp/is_cutiepi_image" ]; then
    echo "initial flash - setup cutiepi image"

    cp /boot/cutiepi/config.txt.twrp.cutiepi /boot/config.txt.twrp 
    cp /boot/cutiepi/config.txt.rom.cutiepi /boot/config.txt.rom 
    cp /boot/cutiepi/cmdline_cutiepi.txt /boot/cmdline.txt
  fi

  if [ $(readlink /dev/block/by-name/boot) == "/dev/block/sda1" ]; then
      echo "set USB boot"
      disable_property dtoverlay=rpi-android-sdcard /boot/config.txt.rom
      enable_property dtoverlay=rpi-android-usb /boot/config.txt.rom
  fi
  if [ $(readlink /dev/block/by-name/boot) == "/dev/block/mmcblk0p1" ]; then
      echo "set SD boot"
      enable_property dtoverlay=rpi-android-sdcard /boot/config.txt.rom
      disable_property dtoverlay=rpi-android-usb /boot/config.txt.rom
  fi
else

  echo "update flash - restore config.txt files"

  if [ -f "/tmp/config.txt" ]; then
    cp /tmp/config.txt /boot/
  fi
  if [ -f "/tmp/config.txt.rom" ]; then
    cp /tmp/config.txt.rom /boot/
  fi
  if [ -f "/tmp/config.txt.twrp" ]; then
    cp /tmp/config.txt.twrp /boot/
  fi
  if [ -f "/tmp/cmdline.txt" ]; then
    cp /tmp/cmdline.txt /boot/
  fi

#  echo "update flash - dont restore config.txt files"

#  if [ $(readlink /dev/block/by-name/boot) == "/dev/block/sda1" ]; then
#      echo "set USB boot"
#      disable_property dtoverlay=rpi-android-sdcard /boot/config.txt.rom
#      enable_property dtoverlay=rpi-android-usb /boot/config.txt.rom
#  fi
#  if [ $(readlink /dev/block/by-name/boot) == "/dev/block/mmcblk0p1" ]; then
#      echo "set SD boot"
#      enable_property dtoverlay=rpi-android-sdcard /boot/config.txt.rom
#      disable_property dtoverlay=rpi-android-usb /boot/config.txt.rom
#  fi
fi

echo "set ROM boot"
cp /boot/config.txt.rom /boot/config.txt

exit 0
