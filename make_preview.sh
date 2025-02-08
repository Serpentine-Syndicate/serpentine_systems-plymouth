#!/usr/bin/env bash

# Set the source directory for the PNG frames
SRC_DIR="src/serpentinesystems"
OUTPUT_FILE="serpentine-preview.gif"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: Source directory $SRC_DIR not found"
    exit 1
fi

echo "Creating animation preview from PNG frames..."

# Create a temporary list of files in correct order
frame_list=""
frame_count=1  # Start at 1
while [ -f "$SRC_DIR/progress-$frame_count.png" ]; do
    frame_list="$frame_list $SRC_DIR/progress-$frame_count.png"
    ((frame_count++))
done

# Adjust frame_count to show actual number of frames
((frame_count--))

if [ -z "$frame_list" ]; then
    echo "Error: No progress-X.png frames found in $SRC_DIR"
    exit 1
fi

echo "Found $frame_count frames"

# Create the animation
# -delay 5 = 20fps (5/100 seconds per frame)
# -loop 0 = infinite loop
convert -delay 5 -loop 0 -background black $frame_list "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Successfully created $OUTPUT_FILE"
    echo "You can add this to your README.md with:"
    echo "![Serpentine Systems Boot Animation](./$OUTPUT_FILE)"
else
    echo "Error: Failed to create animation"
    exit 1
fi 