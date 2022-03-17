# Creating icons
------------------

If you want to contribute by creating new icons, this can easily be done on any computer.

1. Install Inkscape
2. Add the color palette to inkscape
3. (optional) Add the templates to inkscape

## Installation

Ubuntu/Debian:
```
sudo apt update
sudo apt install inkscape
```
Fedora:
```
sudo dnf update
sudo dnf install inkscape
```

## Color palette
You can find the nord color palette and a Nord modified color palette that contains some additional colors [here](https://github.com/alvatip/Nordzy-icon/tree/main/tools/palettes)

To add the color palette to Inkscape, move the nord.gpl and/or nord_modified.gpl files to ` $HOME/.config/inkscape/palette/ `. 
```
# Example to download and move the color palette to Inkscape

# Clone the Nordzy-icon repository
git clone https://github.com/alvatip/Nordzy-icon.git

# Copy the color palettes to Inkscape
cp Nordzy-icon/tools/palettes/* $HOME/.config/inkscape/palettes/
```

> note: If inkscape was open, restart it for the changes to take effect

Finally, in Inkscape, switch to the Nord/Nord modified color palette. More informations on how to change the color palette in Inkscape are [here](https://inkscape-manuals.readthedocs.io/en/latest/palette.html).
## Templates
As a starting point to create applications icons, [here](https://github.com/alvatip/Nordzy-icon/tree/main/tools/templates) are some templates.
You can add them in Inkscape by moving the templates to `$HOME/.config/inkscape/templates/ `
```
# Example to download and move the templates to Inkscape

# Clone the Nordzy-icon repository
git clone https://github.com/alvatip/Nordzy-icon.git

# Copy the color palettes to Inkscape
cp Nordzy-icon/tools/templates/* $HOME/.config/inkscape/templates/
```
