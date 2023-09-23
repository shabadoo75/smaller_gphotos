#!/bin/bash

# Constants
VIDEO_BITRATE="2M"  # the video bitrate in megabits/s
JPEG_QUALITY="10"  # choose a value of 2 - 31 with 2 being best quality, 31 worst
OUTPUT_DIRECTORY="small" # save the smaller output here
TIMEZONE="+0000" # Google photos uses UTC for filenames, dont change this

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIRECTORY

# Convert a Google photos file name to a formtted datetime
filename2datetime() {
  local file="$1"

  local ctime=$(echo "$file" | sed -n 's/.*PXL_\([0-9]\{8\}\)_\([0-9]*\).*/\1:2/p')

  local date_part=$(echo "$ctime" | cut -d':' -f1)
  local time_part=$(echo "$ctime" | cut -d':' -f2)

  local formatted_date="${date_part:0:4}-${date_part:4:2}-${date_part:6:2}"
  local formatted_time="${time_part:0:2}:${time_part:2:2}:${time_part:4:2} $TIMEZONE"

  echo "$formatted_date $formatted_time"
}

# Convert movies
convert_movies() {
  for file in $(ls | grep -E "(mp4|mpeg)$"); do
    ffmpeg -y -i "$file" -c:v libx265 -b:v $VIDEO_BITRATE "$OUTPUT_DIRECTORY/$file"

    local formatted_ctime=$(filename2datetime "$file")

    touch -a -m -d "$formatted_ctime" "$OUTPUT_DIRECTORY/$file"
  done
}

# Convert pictures
convert_pictures() {
  for file in $(ls | grep -E "(jpg|jpeg)$"); do
    ffmpeg -y -i "$file" -qscale:v $JPEG_QUALITY "$OUTPUT_DIRECTORY/$file"

    local formatted_ctime=$(filename2datetime "$file")

    touch -a -m -d "$formatted_ctime" "$OUTPUT_DIRECTORY/$file"
  done
}

# Main execution
convert_movies
convert_pictures
