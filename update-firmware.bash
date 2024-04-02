LEFT_KB_FIRMWARE=./firmware/ergonaut_one_left-seeeduino_xiao_ble-zmk.uf2
RIGHT_KB_FIRMWARE=./firmware/ergonaut_one_right-seeeduino_xiao_ble-zmk.uf2

DEVICE_LABEL="XIAO-SENSE"

function load_firmware {
  last_run=$(gh run list --json databaseId -q '.[0].databaseId')
  echo "Loading firmware from job run id: $last_run"

  status=$(gh run view "$last_run" --json status -q '.status')

  if [ "$status" != "completed" ]; then
    echo 'The job still not completed. Stopping script.'
    exit 0
  fi

  conclusion=$(gh run view "$last_run" --json conclusion -q '.conclusion')

  if [ "$conclusion" != "success" ]; then
    echo 'The job is unsuccecful. Please visit page for more detail.'
    exit 1
  fi

  if [ -d firmware ]; then
    rm -r firmware
  fi

  gh run download "$last_run"
}

function flash_keyboard {
  SOURCE_FIRMWARE=$1

  echo "Mount please your keyboard!"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then

    disk_path=$(lsblk -O --json | jq ".blockdevices[] | select(.label == \"$DEVICE_LABEL\") | .path")

    while [[ "$disk_path" == "" ]]; do
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

    while [[ ! -d $TARGET_DIR ]]; do
      sleep 1
    done

    sudo cp "$SOURCE_FIRMWARE" "$TARGET_DIR"

    sleep 5

  else
    echo "Unknown OS!"
    exit 1
  fi
}

load_firmware
printf "Done!\n\n"

sudo echo "Use your right keyboard."
flash_keyboard $RIGHT_KB_FIRMWARE
printf "Done!\n\n"

echo "Use your left keyboard."
flash_keyboard $LEFT_KB_FIRMWARE
printf "Done!\n\n"
