# GimpScan
A GIMP plugin to import images from scanners on macOS.

## Installation
Download the binary from https://github.com/SimulPiscator/GimpScan/releases/download/v0.41/GimpScan.zip, and unpack it to a permanent location such as /Applications/Utilities. 
Then, run it by ctrl-clicking and choosing "Open..." from the context menu, and confirming that you want to run it.
If you have the GIMP installed in your /Applications folder, GimpScan will prompt you whether to install or to abort the operation.
After confirmation, it will install itself into the GIMP's plugin directory, which is located inside the GIMP application.
If the GIMP is running, restart it to use the new plugin.

## Deinstallation
Double-click GimpScan. If it has been installed before, it will ask you whether to uninstall.

## Usage
Choose File->Create->Scanner... from the GIMP's menu. This will run the plugin. It displays a view of the scanner that is provided by the OS, as known from Apple Image Capture.

![grafik](https://user-images.githubusercontent.com/28909687/82439507-15870500-9a9b-11ea-84bc-753f9883e3be.png)

Click "Scan to GIMP". This will perform a scan to a temporary file in the selected format, and open the temporary file in the GIMP.

![grafik](https://user-images.githubusercontent.com/28909687/82439821-9940f180-9a9b-11ea-8c77-1b6a0b87a5e0.png)

The temporary file will be deleted as soon as it has been opened by the GIMP.

## Glitches
* In the scanner view, the user is able to choose from a number of file formats for the temporary file. However, some file formats will not work for import by the GIMP. It is best to stick with TIFF.
* When format is TIFF and orientation is set to upside down in the scanner view, it appears that the GIMP treats the file correctly but it displays a warning message related to the image's "background".
* Sometimes, the GIMP's progress bar displays the name of the temporary file, and stays frozen near the end. The file appears to be read properly, though.
* When the scanner view has been used with a scanner before, it tries to connect to that scanner when opening up and fails, but
immediately succeeds when retrying. The Apple Image Capture program uses the same ImageKit components but does not show that behavior.
