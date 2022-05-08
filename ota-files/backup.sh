#!/sbin/sh

echo "run backup"

if [ -f "/boot/is_recovery_image" ]; then
  echo "initial flash"
  cp /boot/is_recovery_image /tmp/
else
  echo "update flash"
  if [ -f "/boot/config.txt" ]; then
    cp /boot/config.txt /tmp/
  fi
  if [ -f "/boot/config.txt.rom" ]; then
    cp /boot/config.txt.rom /tmp/
  fi
  if [ -f "/boot/config.txt.twrp" ]; then
    cp /boot/config.txt.twrp /tmp/
  fi
  if [ -f "/boot/cmdline.txt" ]; then
    cp /boot/cmdline.txt /tmp/
  fi
fi

exit 0
