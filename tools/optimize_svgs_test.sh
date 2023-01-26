#!/bin/bash

# Function that optimize all the svgs in the src/ folder and subfolders using scour
optimize(){
	for file in $(find ../src/ -name "*.svg")
	do
		scour \
			-i "$file" -o "$file".tmp\
			--disable-simplify-colors \
			--disable-style-to-xml \
			--remove-metadata \
			--renderer-workaround \
			--strip-xml-prolog \
			--set-precision=8 \
			--strip-xml-space

		# rename
		mv -f "$file".tmp "$file"

	done
}

# Check that optimize() did not break any files. 
# The only current break I noticed was some SVG files that were empty after using scour
# Thus this function will search for empty files (0 bytes), if it find some, 
# it will restore the files and display a message to the user letting him know he should inspect these files
check(){
	# Display a message
	clear
	echo "Searching for files broken during optimization..."
	echo "The following files are broken:"
	# find all file with size == 0
	for file in $(find ../src/ -size 0)
	do
		# Display broken files
		echo $file
		# Restore broken files
		git restore $file
	done
}

# Running all operations
optimize
check