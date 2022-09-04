#!/bin/bash

# Optimize all the svgs in the folder and subfolder
for file in $(find . -name "*.svg")
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
echo "done"