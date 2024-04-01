LEFT_KB_FIRMWARE=./firmware/ergonaut_one_left-seeeduino_xiao_ble-zmk.uf2
RIGHT_KB_FIRMWARE=./firmware/ergonaut_one_right-seeeduino_xiao_ble-zmk.uf2

DEVICE_LABEL="XIAO-SENSE"

function flash_keyboard {
  SOURCE_FIRMWARE=$1

  echo "Mount please your keyboard!"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    disk_path=$(lsblk -O --json | jq ".blockdevices[] | select(.label == \"$DEVICE_LABEL\") | .path")

    while [[ "$disk_path" == "" ]]
    do
      disk_path=$(lsblk -O --json | jq ".blockdevices[] | select(.label == \"$DEVICE_LABEL\") | .path")
      sleep 1
    done

    echo "The keyboard is mounted!"

    TARGET_DIR="device"

    # Expand string for right device mounting
    # "/dev/disk" -> /dev/disk
    disk_path=$(cut -d \" -f 2 <<< "$disk_path")

    mkdir "$TARGET_DIR"

    sudo mount "$disk_path" "$TARGET_DIR"
    sudo cp "$SOURCE_FIRMWARE" "$TARGET_DIR"
    sudo umount "$TARGET_DIR"

    rm -r "$TARGET_DIR"

  elif [[ "$OSTYPE" == "darwin"* ]]; then

    TARGET_DIR=/Volumes/$DEVICE_LABEL

    while [[ ! -d $TARGET_DIR ]]
    do
      sleep 1
    done

    cp "$SOURCE_FIRMWARE" "$TARGET_DIR"

  else
    echo "Unknown OS!"
    exit 1
  fi
}

sudo echo "Use your right keyboard."
flash_keyboard $RIGHT_KB_FIRMWARE
echo "Done!"
echo ""

echo "Use your left keyboard."
flash_keyboard $LEFT_KB_FIRMWARE
echo "Done!"
echo ""
