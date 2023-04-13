from re import match
from pathlib import Path


class DesktopFile:
    """Representation of a desktop file created by AppImage Launcher

    Methods:

    change_icon_name -- Change long icon name created by AppImage Launcher with a shorter icon name
                        from Nordzy-icon theme.

    Variables:

    path -- The path to the desktop file.
    appname -- The name of the application represented by the desktop file.
    filename -- The name of the desktop file.
    """
    def __init__(self, path, appname, filename):
        self.path = path
        self.appname = appname
        self.name = filename

    def __str__(self):
        return f"File: {self.name}\n" \
               f"Application: {self.appname}\n" \
               f"Path: {self.path}"

    def change_icon_name(self):
        """Change long icon name created by AppImage Launcher with a shorter icon name from Nordzy-icon theme

        Behaviour:
        The function reads each line of the current desktop file,
        if the line does not start with 'Icon=', the line is not changed and wrote into a temporary file ('.temp').
        if the line does start with 'Icon=', the name of the icon is modified before being written into the temporary
        file ('.temp').
        Since all the desktop files created by AppImage Launcher contains two lines beginning with 'Icon=', but only the
        first line needs to be modified, a flag is created and its value is turned to true when the first line is found,
        avoiding modifying the second line starting with 'Icon='.
        At the end, current desktop file is replaced with temporary file recently created. The temporary file is an
        exact copy of the current file with the first line starting with 'Icon=' modified.
        """
        flag_line_found = False
        temp_file = Path(str(self.path) + ".temp")
        with open(self.path, 'r+') as f:
            # Create a temporary file to write the modified version of the original file
            with open(temp_file, 'w+') as f2:
                # write each line of the file into the temporary file
                for line in f.readlines():
                    # check for the line defining the icon
                    pattern_icon = "^Icon=.*"
                    # Using a flag to avoid matching every line after the line was found
                    if not flag_line_found:
                        if match(pattern_icon, line):
                            # Replace the line setting the icon with a custom one pointing to a Nord themed icon
                            f2.write(f"Icon={self.appname}.svg\n")
                            flag_line_found = True
                        else:
                            f2.write(line)
                    else:
                        f2.write(line)
                    f2.flush()
        # Replace old file with the newly created version
        temp_file.replace(self.path)
        # Give the execution permission to the file
        self.path.chmod(0o766)


if __name__ == "__main__":
    appimage_desktop_path = Path.joinpath(Path.home(), ".local/share/applications")

    # Create a DesktopFile object for each file matching the pattern of the .desktop file created by AppImageLauncher
    # and store them in a list.
    pattern = "appimagekit_.*-(.*)\.desktop"
    files = []
    try:
        for file in appimage_desktop_path.iterdir():
            matching = match(pattern, str(file.name))
            if matching:
                files.append(DesktopFile(file, matching.group(1).lower(), str(file.name)))
    # If an error is thrown because the file does not exist
    except FileNotFoundError:
        print(f"The path {appimage_desktop_path} does not point to an existing file or directory")
        exit(1)

    # Print a summary:
    # Should contain a message if no file were found
    # List the number of file that were altered as well as the name of the applications that were concerned
    if len(files) == 0:
        print(f"There are no desktop file at the mentioned location ({appimage_desktop_path})")
    else:
        print(f"{len(files)} files were modified:")
        for file in files:
            # Open the file, find the name setting the icon and change it to match the name of the application
            # which match the corresponding icon in Nordzy theme
            file.change_icon_name()
            print(f"    - {file.name} (App: {file.appname})")
