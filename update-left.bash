SOURCE_FIRMWARE=./firmware/ergonaut_one_left-seeeduino_xiao_ble-zmk.uf2
TARGET_DIR=/Volumes/XIAO-SENSE

if [ ! -d $TARGET_DIR ]; then
  echo "The left keyboard is not mounted!"
  exit 1
fi

cp "$SOURCE_FIRMWARE" "$TARGET_DIR"
