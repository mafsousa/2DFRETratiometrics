# 2D FRET ratiometrics


2D FRET ratiometric analysis 
v0.1

This is a generic macro to perform 2D FRET ratiometric analysis into individual cell images. The main workflow is composed of an illumination 
correction; background subtraction from the noisy image or with mean value; structure/cell segmentation and FRET ratiometric analysis.
 
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
