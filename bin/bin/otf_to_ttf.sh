#!/bin/bash
# A script to convert all OTF files in a specified directory to TTF format using FontForge

# Check if FontForge is installed
if ! command -v fontforge &>/dev/null; then
	echo "FontForge is not installed. Please install it with: brew install fontforge"
	exit 1
fi

# Check if a directory path is provided
if [[ -z "$1" ]]; then
	echo "Usage: $0 /path/to/directory"
	exit 1
fi

# Assign the first argument as the target directory
TARGET_DIR="$1"

# Check if the provided path is a valid directory
if [[ ! -d "$TARGET_DIR" ]]; then
	echo "Error: $TARGET_DIR is not a valid directory."
	exit 1
fi

# Convert each .otf file to .ttf in the specified directory
for otf_file in "$TARGET_DIR"/*.otf; do
	# Skip if no .otf files are found
	if [[ ! -e "$otf_file" ]]; then
		echo "No .otf files found in $TARGET_DIR."
		exit 0
	fi

	# Get the base name without extension
	base_name="${otf_file%.*}"
	ttf_file="${base_name}.ttf"

	# Convert using FontForge
	echo "Converting $otf_file to $ttf_file..."
	fontforge -lang=ff -c "Open(\"$otf_file\"); Generate(\"$ttf_file\")"

	# Check if the conversion was successful
	if [[ -e "$ttf_file" ]]; then
		echo "Successfully converted: $otf_file -> $ttf_file"
	else
		echo "Failed to convert: $otf_file"
	fi
done

echo "Conversion process completed."
