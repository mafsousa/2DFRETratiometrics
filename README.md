# 2D FRET ratiometrics

## Description
2DFRETratiometrics is an ImageJ macro for image analysis, that covers the processing of raw image data sets into ratiometric measurements, capable of illustrating relative differences in the protein activation states within a single cell. This tool was spcifically developed to analyse ratiometric FRET signal on images acquired in widefield inverted microscopes or laser point scanning confocal systems. This tool follows the main steps of the ratiometric FRET analysis pipeline, including multiple options of background subtraction, uneven illumination correction, object segmentation and the ratiometric measurements of FRET.

Inline-style: 
![alt text]
 
## Input:
* File in .tif or .tiff formats, 2D with two or three channels
* Divided into two modes: 
 1. single image already opened 
 2. batch mode, to process a folder of images. 
## Output: 
The macro can output 5 types of files:
* The 2D_FRET_ratiometrics RGB: an RGB image with royal LUT to illustrate the FRET ratio
* The 2D_FRET_ratiometrics output results for each image: .xls file with mean grey values of structure/cell FRET
* The 2D_FRET_ratiometrics output results for all images in batch mode: .xls file with mean grey values 
* The structure/cell mask: The mask applied to the original image, for quality control.
* The Roi outline of the structure/cell.
 
## Prerequisites: 
* Run on ImageJ/Fiji v1.53
* Install plugin Polynomial Shadig Corrector, by OptiNav (https://www.optinav.info/Polynomial_Shading_Corrector.htm)
 				
## Install/run:
* Download the "2D_FRET_ratiometrics.ijm" macro file somewhere on your computer (You can put it in Fiji "macros" folder for example)
* Start Fiji.
* In Fiji, run the macro: Plugins > Macros > Run…, and then select the “2D_FRET_ratiometrics.ijm” file.

## License
This macro should NOT be redistributed without the author's permission. 
Explicit acknowledgement to the ALM facility should be done in case of published articles (approved in C.E. 7/17/2017):     
 
"The authors acknowledge the support of i3S Scientific Platform Advanced Light Microscopy, member of the national infrastructure PPBI-Portuguese Platform of BioImaging  (supported by POCI-01-0145-FEDER-022122)."

Date: October/2020
Author: Mafalda Sousa, mafsousa@ibmc.up.pt 
Advanced Light Microscopy, I3S 
PPBI-Portuguese Platform of BioImaging
