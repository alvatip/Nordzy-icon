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

# Display ascii art
ascii_art() {
  cat < nordzy-ascii-art.txt
  sleep 2
}

# Show help
usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -t, --theme VARIANT     Specify theme color variant(s) [default|purple|pink|red|orange|yellow|green|turquoise|cyan|all] (Default: blue)
    -c, --color VARIANT     Specify color variant(s) [standard|light|dark] (Default: All variants)s)
    -h, --help              Show help
EOF
}

# all the folders from /src to the destination
# use: base_theme
base_theme(){
  echo "Install the base theme"
  mkdir -p                                                                               ${THEME_DIR}/{apps,categories,emblems,devices,mimes,places,status}
  cp -r ${SRC_DIR}/src/{actions,animations,apps,categories,devices,emblems,mimes,places} ${THEME_DIR}
  cp -r ${SRC_DIR}/src/status/{16,22,24,32,scalable}                                     ${THEME_DIR}/status
  cp -r ${SRC_DIR}/links/{actions,apps,categories,devices,emblems,mimes,places,status}   ${THEME_DIR}
}

change_color(){
  echo "change the color from dark to light"
  sed -i "s/#2e3440/#d8dee9/g" "${THEME_DIR}"/{actions,devices,places,status}/{16,22,24}/*
  sed -i "s/#2e3440/#d8dee9/g" "${THEME_DIR}"/actions/32/*
  sed -i "s/#2e3440/#d8dee9/g" "${THEME_DIR}"/{actions,apps,categories,emblems,devices,mimes,places}/symbolic/*
}

change_panel(){
  # if Panel option is specified, the panel var become TRUE and we are going to this function to make it opposite as the color
  # It also changes the name to indicate that the panel as changed
  # if panel option is not specified, then nothing happens
  echo "change the panel from dakr to light"
  sed -i "s/#2e3440/#d8dee9/g" "${THEME_DIR}"/status/{16,22,24}/*
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

  local THEME_DIR=${dest}/${name}${theme}${color}

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
    theme_color ${themes}
  fi
  if [[ ${color} == '-dark' ]]; then
    # Install base theme
    base_theme

    # Change icon color for dark theme
    change_color
    change_panel
    # If another color is specified
    theme_color ${themes}
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

  gtk-update-icon-cache ${THEME_DIR}
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
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
        # echo "Installing '${theme}' folder version..."
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

install_theme() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
    done
  done
}

ascii_art
install_theme
