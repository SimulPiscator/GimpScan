# GimpScan
A GIMP plugin to import images from scanners on macOS.

## Usage
Choosing File->Create->Scanner... in the GIMP will run the plugin, which displays an Apple ImageKit view of the scanner.
![grafik](https://user-images.githubusercontent.com/28909687/82439507-15870500-9a9b-11ea-84bc-753f9883e3be.png)

Clicking "Scan to GIMP" will perform a scan to a temporary file in the selected format, and open that file in the GIMP.
![grafik](https://user-images.githubusercontent.com/28909687/82439821-9940f180-9a9b-11ea-8c77-1b6a0b87a5e0.png)

The temporary file will be deleted as soon as it has been opened by the GIMP.

## Glitches
* In the scanner view, the user is able to choose from a number of file formats for the temporary file. However, some file formats will not work for import by the GIMP. It is best to stick with TIFF.
* When format is TIFF and orientation is set to upside down in the scanner view, it appears that the GIMP treats the file correctly but it displays a warning message related to the image's "background".
* Sometimes, the GIMP's progress bar displays the name of the temporary file, and stays frozen near the end. The file appears to be read properly, though.
* When the scanner view has been used with a scanner before, it tries to connect to that scanner when opening up and fails, but
immediately succeeds when retrying. The Apple Image Capture program uses the same ImageKit components but does not show that behavior.
