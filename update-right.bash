SOURCE_FIRMWARE=./firmware/ergonaut_one_right-seeeduino_xiao_ble-zmk.uf2
TARGET_DIR=/Volumes/XIAO-SENSE

if [ ! -d $TARGET_DIR ]; then
  echo "The right keyboard is not mounted!"
  exit 1
fi

cp "$SOURCE_FIRMWARE" "$TARGET_DIR"
