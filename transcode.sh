#!/bin/bash

# Constants
VIDEO_BITRATE="2M"
JPEG_QUALITY="10"
OUTPUT_DIRECTORY="small"
TIMEZONE="+0000"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIRECTORY

# Function to format timestamp from filename
format_ctime() {
  local ctime="$1"

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

    local ctime=$(echo "$file" | sed -n 's/.*PXL_\([0-9]\{8\}\)_\([0-9]*\).*/\1:2/p')
    local formatted_ctime=$(format_ctime "$ctime")

    touch -a -m -d "$formatted_ctime" "$OUTPUT_DIRECTORY/$file"
  done
}

# Convert pictures
convert_pictures() {
  for file in $(ls | grep -E "(jpg|jpeg)$"); do
    ffmpeg -y -i "$file" -qscale:v $JPEG_QUALITY "$OUTPUT_DIRECTORY/$file"

    local ctime=$(echo "$file" | sed -n 's/.*PXL_\([0-9]\{8\}\)_\([0-9]*\).*/\1:\2/p')
    local formatted_ctime=$(format_ctime "$ctime")

    touch -a -m -d "$formatted_ctime" "$OUTPUT_DIRECTORY/$file"
  done
}

# Main execution
convert_movies
convert_pictures