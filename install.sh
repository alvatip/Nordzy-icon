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
