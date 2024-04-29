#!/bin/bash

ROOT_UID=0
DEST_DIR=

# Destination directory
# Check root user
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Nordzy
COLOR_VARIANTS=('' '-dark')
THEME_VARIANTS=('' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-turquoise' '-cyan')
hex_white='#d8dee9'
hex_dark='#2e3440'
update_cache='TRUE'

# Display ascii art
ascii_art() {
  cat < nordzy-ascii-art.txt
  sleep 0.5
}

# Error message
error_msg(){
  local subject=${1}
  echo "ERROR: Unrecognized ${subject} option '$2'."
  echo "Try '$0 --help' for more information."
  exit 1
}

# Show help
usage() {
cat << EOF
$0 helps you install Nordzy-icon theme on your computer.

Usage: $0 [OPTION]...

OPTIONS:
  -c, --color VARIANT     Specify color variant(s) [standard|light|dark] (Default: All variants)
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
  -g                      Update gtk icon cache
  -n, --name NAME         Specify theme name (Default: $THEME_NAME)
  -p, --panel             Make panel's color opposite to the color variant of the theme (Default: same as color variant)
  -t, --theme VARIANT     Specify theme color variant(s) [default|purple|pink|red|orange|yellow|green|turquoise|cyan|all] (Default: blue)
  --total                 Install all theme, color and panel variants
  -h, --help              Show help
EOF
}

# all the folders from /src to the destination
# use: base_theme
base_theme(){
  mkdir -p                                                                               ${THEME_DIR}/{apps,categories,emblems,devices,mimes,places,status}
  cp -r ${SRC_DIR}/src/{actions,animations,apps,categories,devices,emblems,mimes,places} ${THEME_DIR}
  cp -r ${SRC_DIR}/src/status/{16,22,24,32,scalable}                                     ${THEME_DIR}/status
  cp -r ${SRC_DIR}/links/{actions,apps,categories,devices,emblems,mimes,places,status}   ${THEME_DIR}
}

change_color(){
  # Loop to avoid getting the error: "./install.sh: line 64: /bin/sed: Argument list too long"
  for ICONTYPE in actions devices places status 
  do
    for i in 16 22 24
    do
      sed -i "s/${hex_dark}/${hex_white}/g" "${THEME_DIR}"/${ICONTYPE}/${i}/*
    done
  done
  sed -i "s/${hex_dark}/${hex_white}/g" "${THEME_DIR}"/actions/32/*
  sed -i "s/${hex_dark}/${hex_white}/g" "${THEME_DIR}"/{actions,apps,categories,emblems,devices,mimes,places}/symbolic/*
}

# Change the color of the icons panel from dark to light (light) or from light to dark (dark)
# Default option is from light to dark (dark)
# use: change_panel light/dark
change_panel(){
  # if Panel option is specified, the panel var become TRUE and we are going to this function to make it opposite as the color
  # It also changes the name to indicate that the panel as changed
  # if panel option is not specified, then nothing happens
  if [[ ${1} == 'light' ]] ; then
    # switch from dark to light
    sed -i "s/${hex_dark}/${hex_white}/g" "${THEME_DIR}"/status/{16,22,24}/*
  else
    # switch from light to dark
    sed -i "s/${hex_white}/${hex_dark}/g" "${THEME_DIR}"/status/{16,22,24}/*
  fi
}

# Script to change the color of the specified SVG/icon
# This function is used with apply_plain_color to change all colors to a non nord version of the theme.
substitute_color (){
	sed -i "s/$1/$2/g" "${THEME_DIR}"/actions/{16,22,24,32,symbolic}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/animations/{16,22,24}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/apps/{scalable,symbolic}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/categories/{32,symbolic}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/devices/{16,22,24,scalable,symbolic}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/emblems/{16,22,24,symbolic}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/mimes/{16,22,scalable,symbolic}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/places/{16,22,24,scalable,symbolic}/*
	sed -i "s/$1/$2/g" "${THEME_DIR}"/status/{16,22,24,32,scalable}/*
}

# Using the substitute_color function, this function will replace all the Nord Color with Plain colors.
apply_plain_color(){
    echo "Converting Nord colors to plain colors ..."
    #dark1
    substitute_color "#2e3440" "#000000"

    #dark2
    substitute_color "#3b4252" "#241f31"

    #dark3
    substitute_color "#434c5e" "#3d3846"

    #dark4
    substitute_color "#4c566a" "#5e5c64"

    #dark5
    substitute_color "#7b88a1" "#77767b"

    #dark6
    substitute_color "#a6aebf" "#9a9996"

    #light3
    substitute_color "#d8dee9" "#deddda"

    #light2
    substitute_color "#e5e9f0" "#f6f5f4"

    #light1
    substitute_color "#eceff4" "#ffffff"

    #blue
    substitute_color "#81a1c1" "#3584e4"

    #bluedark
    substitute_color "#5e81ac" "#1a5fb4"

    #yellow
    substitute_color "#ebcb8b" "#f6d32d"

    #yellowdark
    substitute_color "#eac57b" "#e5a50a"

    #turquoise
    substitute_color "#8fbcbb" "#37c8ab"

    #red
    substitute_color "#bf616a" "#e01b24"

    #reddark
    substitute_color "#b54a55" "#a51d2d"

    #purple
    substitute_color "#b48ead" "#9141ac"

    #purpledark
    substitute_color "#ad85a5" "#613583"

    #pink
    substitute_color "#dbc7c5" "#dc8add"

    #orange
    substitute_color "#d08770" "#ff7800"

    #green
    substitute_color "#a3be8c" "#33d17a"

    #greendark
    substitute_color "#97b67c" "#26a269"

    #cyan
    substitute_color "#88c0d0" "#00b7eb"

    #brown1
    substitute_color "#6b5756" "#63452c"

    #brown2
    substitute_color "#8c7e75" "#865e3c"

    #brown3
    substitute_color "#a88279" "#b5835a"

    #brown4
    substitute_color "#c4b0a7" "#cdab8f"
}

# change the color of the theme when specified
# use: theme_color $theme
theme_color() {
  if [[ ${1} != '' ]]; then
    cp -r ${SRC_DIR}/colors/color${1}/*.svg                                          ${THEME_DIR}/places/scalable
  fi
}

install() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local color=${4}

  # Modify the name of the theme according to colors and panel color
  if [[ ${panel} == 'TRUE' ]] && [[ ${color} == '-dark' ]]; then
    local THEME_DIR=${dest}/${name}${theme}${color}--light_panel
  elif [[ ${panel} == 'TRUE' ]] && [[ ${color} == '' ]]; then
    local THEME_DIR=${dest}/${name}${theme}${color}--dark_panel
  else 
    local THEME_DIR=${dest}/${name}${theme}${color}
  fi

  # If theme dir exist: remove it
  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  # which theme, in which directory
  echo "Installing '${THEME_DIR}'..."

  # copy files to theme dir
  mkdir -p                                                                             ${THEME_DIR}
  cp -r ${SRC_DIR}/{COPYING,AUTHORS}                                                   ${THEME_DIR}
  cp -r ${SRC_DIR}/src/index.theme                                                     ${THEME_DIR}

  cd ${THEME_DIR}
  sed -i "s/${name}/${name}${theme}${color}/g" index.theme

  # install default color
  if [[ ${color} == '' ]]; then
    
    # Install the base theme
    base_theme
    # If another theme color is specified
    theme_color ${theme}
    if [[ ${panel} == 'TRUE' ]]; then
      # Panel color must be light
      change_panel light
    fi

    # If we want the color to be converted to plain colors.
    if [[ ${plain_color} = 'TRUE' ]]; then
        # Call the function apply_plain_color
        apply_plain_color
    fi
  fi
  if [[ ${color} == '-dark' ]]; then
    # Install base theme
    base_theme

    # Change icon color for dark theme
    change_color
    # If another color is specified
    theme_color ${theme}
    if [[ ${panel} == 'TRUE' ]]; then
      # Panel color must be light
      change_panel dark
    fi

    # If we want the color to be converted to plain colors.
    if [[ ${plain_color} = 'TRUE' ]]; then
        # Call the function apply_plain_color
        apply_plain_color
    fi
  fi

  (
    cd ${THEME_DIR}
    ln -sf actions actions@2x
    ln -sf animations animations@2x
    ln -sf apps apps@2x
    ln -sf categories categories@2x
    ln -sf devices devices@2x
    ln -sf emblems emblems@2x
    ln -sf mimes mimes@2x
    ln -sf places places@2x
    ln -sf status status@2x
  )

  if [[ ${update_cache} == 'TRUE' ]]; then
    gtk-update-icon-cache ${THEME_DIR}
  fi
}

install_theme() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
    done
  done
}

# Install all the theme, color and panel variants
all_variants_installation(){
  themes=("${THEME_VARIANTS[@]}")
  colors=("${COLOR_VARIANTS[@]}")
  ascii_art
  for bool in 'TRUE' 'FALSE'; do
    panel=${bool}
    install_theme
  done
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -c|--color)
      shift
      for color in "${@}"
      do
        case ${color} in
          default)
            colors=("${COLOR_VARIANTS[@]}")
            shift
            ;;
          light)
            colors=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            error_msg "color" ${1}
            ;;
        esac
      done
      ;;
    -p|--panel)
      panel=TRUE
      shift
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          turquoise)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          cyan)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            error_msg 'theme' ${1}
            ;;
        esac
        # echo "Installing '${theme}' folder version..."
      done
      ;;
    --total)
      all_variants_installation
      exit 0
      ;;
    -g)
      update_cache='FALSE'
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -v|--variant)
      plain_color='TRUE'
      shift
      ;;
    *)
      error_msg 'installation' ${1}
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

ascii_art
install_theme
