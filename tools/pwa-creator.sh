#!/bin/bash

# Created by Davis Forsythe

# Parse command-line arguments
ARGS=$(getopt -o hf:i:o: --long help,file:,id:,output: -n "$0" -- "$@")
eval set -- "$ARGS"

browsers=('chrome' 'edge' 'vivaldi' 'brave' 'opera')

# Help message
display_help() {
cat << EOF
$(basename $0) takes an app icon in the src directory and creates various symlinks to make it work as an icon for progressive web apps.
Usage: $0 [options]
Options:
  -h, --help           Display this help message
  -f, --file <file>    Specify a icon file
  -i, --id <id>        Specify the PWA ID
  -o, --output <dir>   Specify an output directory
EOF
}

# Set the default output folder
out_dir="$(dirname "$(realpath "$0")")/../src/apps/scalable"

# Default to help
if [[ $# -eq 1 ]] && [[ $1 == "--" ]]; then
  echo -e "No arguments, showing help:\n"
  display_help
  exit 0
fi

# Process arguments
while true; do
  case "$1" in
    -h | --help)
      display_help
      exit 0
      ;;
    -f | --file)
      shift
      file=$1
      ;;
    -i | --id)
      shift
      id=$1
      ;;
    -o | --output)
      shift
      out_dir=$1
      out_dir=${out_dir%/}
      echo ${out_dir}
      exit 0
      ;;
    --)
      shift
      break
      ;;
    # *)
    #   echo "Invalid option: $1"
    #   exit 1
    #   ;;
  esac
  shift
done

# Check if required arguments are provided
if [[ -z $id ]] || [[ -z $file ]]; then
  echo -e "\033[1;31mERROR\033[0m: Both an icon file and a PWA ID are required"
  exit 1
fi

# Move the icon file to the output directory
icon_name=$(basename "$file")
cp "$file" "$out_dir/$icon_name"


# Create symlinks for each browser
cd $out_dir
for browser in "${browsers[@]}"; do
  symlink_name="${browser}-${id}-Default.svg"
  ln -s "$icon_name" "../../../links/apps/scalable/$symlink_name"
done

echo "PWA links created successfully."
