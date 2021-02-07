#!/bin/bash

ERRORS=()
# set params and throw error if not exists
WIN_USERNAME="${1:-MISSING_USERNAME}"
WIN_WALLPAPER_ASSET_DIR=${2:-MISSING_ASSET_DIRECTORY}

if [[ -z $WIN_USERNAME || $WIN_USERNAME == "MISSING_USERNAME" || -z $WIN_WALLPAPER_ASSET_DIR || $WIN_WALLPAPER_ASSET_DIR == "MISSING_ASSET_DIRECTORY" ]]; then
  ERRORS+=("args not set.");
fi

# create log folder if it does not exist
if [[ ! -d ./logs ]]; then
  mkdir ./logs
fi

# create Wallpaper folder in User Profile Pictures folder
if [[ ! -d /mnt/c/Users/USER/Pictures/Wallpapers ]]; then
  mkdir /mnt/c/Users/USER/Pictures/Wallpapers
fi

COUNT=0 # image counter (results in error if 0 images are found- should always be at least 1 image available)
WIN_ASSET_DIR="/mnt/c/Users/$WIN_USERNAME/AppData/Local/Packages/$WIN_WALLPAPER_ASSET_DIR/LocalState/Assets"
PATH_EXISTS=true # if path does not exist error indication 0 wallpapers will not be thrown

if [[ ! -d "$WIN_ASSET_DIR" ]]; then
  ERRORS+=("Path does not exist.: $WIN_ASSET_DIR")
  PATH_EXISTS=false
fi

# loop thru all images in designated path and copy them to the wallpapers location
for file in $WIN_ASSET_DIR/*; do
  if [[ $(file --mime-type -b "$file") == image/jpeg ]]; then
    IFS=',' read -r -a FILE_DATA <<< $(file "$file")

    if [[ "${FILE_DATA[7]}" == " 1920"* ]]; then
      ((COUNT++))
      FILENAME=$(basename "$file")
      cp -- "$file" "/mnt/c/Users/$WIN_USERNAME/Pictures/Wallpapers/$FILENAME.jpeg"
    fi
  fi
done

# when dedicated path exists but 0 images are found throw an error
if [[ $PATH_EXISTS == "true" && $COUNT == 0 ]]; then ERRORS+=("0 wallpapers found in $WIN_ASSET_DIR/"); fi
# write error to log
if [[ $ERRORS[@] > 0 ]]; then printf "%s\n" "${ERRORS[@]}" > ./logs/error_log_$(date +%s%N).txt; fi
