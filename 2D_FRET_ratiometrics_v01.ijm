//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////// 2D_FRET_ratiometrics //////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////Author: Mafalda Sousa, mafsousa@ibmc.up.pt ////////////////////////////////////////
/////////////////////////// ALM - I3S ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
 
/* 2D FRET ratiometric analysis of Schwann cells (Ana Seixas) 
 * v0.1
*
* This is a generic macro to perform 2D FRET ratiometric. Main workflow is composed by illumination 
* correction; background subtraction from noisy image or with mean value; 
* structure/cell segmentation and FRET ratiometrics analysis
* 
* Input: 
 	 ** File in .tif or .tiff formats, 2D with two or three channels
	 ** Divided in two modes: 
	  		** single image already opened 
	  		** batch mode, to process a folder of images. 
* Output: 
     The macro can output 5 types of files:

      ** The 2D_FRET_ratiometrics RGB: an RGB image with royal LUT to illustrate the FRET ratio
	  ** The 2D_FRET_ratiometrics output results for each image: .xls file with mean grey values of structure/cell FRET
	  ** The 2D_FRET_ratiometrics output results for all images in batch mode: .xls file with mean grey values 
	  ** The structure/cell mask: The mask applied to the original image, for quality control .
	  ** The Roi outline of the structure/cell.
* 
* Prerequisites: Run on ImageJ/Fiji v1.53
 				 Install plugin Polynomial Shadig Corrector, by OptiNav 
 				 (https://www.optinav.info/Polynomial_Shading_Corrector.htm)
 				
* Install/run:
	  ** Download the "2D_FRET_ratiometrics.ijm" macro file somewhere on your computer 
	     (You can put it in the Fiji "macros" folder for example)
   	  ** Start Fiji.
 	  ** In Fiji, run the macro: Plugins > Macros > Run…, and then select the “2D_FRET_ratiometrics.ijm” file.
* 
* This macro should NOT be redistributed without author's permission. 
* Explicit acknowledgement to the ALM facility should be done in case of published articles 
* (approved in C.E. 7/17/2017):     
* 
* "The authors acknowledge the support of i3S Scientific Platform Advanced Light Microscopy, 
* member of the national infrastructure PPBI-Portuguese Platform of BioImaging 
* (supported by POCI-01-0145-FEDER-022122)."
* 
* Date: October/2020
* Author: Mafalda Sousa, mafsousa@ibmc.up.pt 
* Advanced Ligth Microscopy, I3S 
* PPBI-Portuguese Platform of BioImaging
*/

roiManager("reset");
run("Clear Results");

//Input information about channels
Dialog.create("FRET-RATIOMETRICS");
Dialog.addMessage("Define respective channel number.");
Dialog.addNumber("Fret channel", 1);
Dialog.addNumber("Donnor channel", 2);
Dialog.addNumber("Acceptor channel", 3);
Dialog.show();

fret_channel = Dialog.getNumber();    //fret channel
donnor_channel = Dialog.getNumber();  //donnor channel
acceptor_channel = Dialog.getNumber();//acceptor only channel

//Mode input either single or batch
Dialog.create("FRET-RATIOMETRICS");
Dialog.addMessage("Choose between Single file and Batch mode");
Dialog.addChoice("Mode", newArray("Single", "Batch"));
Dialog.show();

Mode = Dialog.getChoice();
// Single mode
if (Mode=="Single"){
	print("=== FRET-RATIOMETRICS Single file mode ===");
	//check if there's images opened
	list = getList("image.titles");
	if (list.length == 0) {
    	Dialog.create("Warning");
    	Dialog.addMessage("No Image opened!");
    	Dialog.show();
    	exit;
	}
	else{
		image_title = getTitle();
		dotIndex = lastIndexOf(image_title, ".");
    	title = substring(image_title, 0, dotIndex); 

    	//check correct input: at least 2 channels
    	getDimensions(width, height, channels, slices, frames);
    	if(channels < 2){
    		Dialog.create("Warning");
    		Dialog.addMessage("Image should have at least 2 channels!");
    		Dialog.show();
    		exit;
    	}
    	//define input directory
    	input_dir = getDirectory("image");
    	//define output directory
    	output_dir = input_dir+File.separator+"FRETResult";
    	if(!File.exists(output_dir)){
			File.makeDirectory(output_dir);
    	}		
    	
		//Correct illumination, background removal
		acpt = preProcessing(image_title);
	
		//create mask and roi with segmented object		
		if(acpt=="Yes"){
			objectSegmentation(acpt);
    	}
		else {
			objectSegmentation(acpt);
		}
	
		//calculate ratio and save results
		fretAnalysis(title,output_dir);

		print("=== DONE ===");
	}
}
else { //Batch mode
	print("=== FRET-RATIOMETRICS Batch file mode ===");
	//get input directory
	input_dir = getDirectory("Choose input directory");
	//define output directory
	output_dir = input_dir + File.separator + "FRETResult";
	if(!File.exists(output_dir)){
		File.makeDirectory(output_dir);
    }		
	count = 0;
	countFiles(input_dir);
	n = 0;
	//process all files iside folder
	processFiles(input_dir, output_dir);
	// join individual image results into an excel file
	print("Merging excel files");
	merge_excel_files(output_dir);

	print("=== DONE ===");
}

//count the number of valid files in the directory     
function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], File.separator))
              countFiles("" + dir + list[i]);
          else
              count++;
      }
  }

// iterate through all the files in the folder in order to process them
function processFiles(input_dir, output_dir) {
      list = getFileList(input_dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], File.separator))
              processFiles(""+input_dir+list[i], output_dir);
          else {
             showProgress(n++, count);
             path = input_dir + File.separator + list[i];
             file_name = list[i];
             if ( (endsWith(path, ".tif") || endsWith(path, ".tiff")) && File.exists(path)){
             	processFile(path,file_name);
             }
          }
      }
}

// process each file
function processFile(path, file_name){
	//open file
	open(path);
	//get image title 
	image_title = getTitle();
	dotIndex = lastIndexOf(image_title, ".");
    title = substring(image_title, 0, dotIndex); 

    //check correct input
    getDimensions(width, height, channels, slices, frames);
    if(channels < 2){
    	Dialog.create("Warning");
    	Dialog.addMessage("Image should have at least 2 channels!");
    	Dialog.show();
    	exit
    }
       
    //Correct illumination, background removal
	acpt = preProcessing(image_title);
	
	//create mask and roi with segmented object		
	if(acpt=="Yes"){
		objectSegmentation(acpt);
    }
	else {
		objectSegmentation(acpt);
	}
	
	//calculate ratio and save results
	fretAnalysis(title,output_dir);
}

function preProcessing(original){

	print("Preprocessing...");

	//Decide to use background image for background subtraction and if acceptor channel is available
	Dialog.create("FRET-RATIOMETRICS");
	Dialog.addMessage("Do you have background image?");
	Dialog.addChoice("Background image:", newArray("Yes", "No"), "No");
	Dialog.addMessage("Do you have an Acceptor only channel?");
	Dialog.addChoice("Acceptor channel:", newArray("Yes", "No"), "No");
	Dialog.show();
	bkg = Dialog.getChoice();
	acpt = Dialog.getChoice();

	//open and split background image
	if (bkg=="Yes"){ 
		noisy_dir = File.openDialog("Select Noisy Image");	   
		if(File.exists(noisy_dir)){
			open(noisy_dir);
			noise = getTitle();
			selectWindow(noise);	
	    	run("Polynomial Shading Corrector", "degree_x=1 degree_y=1 regularization=10");
		    wait(200);
	 		//split channels 
			run("Split Channels"); 
			selectWindow("C" + donnor_channel + "-"+noise);
			donnor_noise = getTitle();
			selectWindow("C" + fret_channel + "-"+noise);
			fret_noise = getTitle();	  
			print("Background subtraction") ; 
		}
		else {
			exit("Invalid background image");
		}
	}   
	  
	 //shading correction of original image
	 selectWindow(original);
	 run("Polynomial Shading Corrector", "degree_x=1 degree_y=1 regularization=10");
	 
	 //split channels 	   
	 run("Split Channels"); 
	 if(acpt=="No"){
	    selectWindow("C" + donnor_channel + "-" + original);
	    donnor = getTitle();
	    selectWindow("C" + fret_channel + "-" + original);
	    fret = getTitle(); 	
	  }
	  else{
	    selectWindow("C" + donnor_channel + "-" + original);
	    donnor = getTitle();
	    selectWindow("C" + fret_channel + "-" + original);
	    fret = getTitle(); 	 
	    selectWindow("C" + acceptor_channel + "-" + original);
	    acceptor = getTitle(); 
	    rename("acceptor"); 
	  }

	  //subtract background in both channels (divide by background image)	
	 if (bkg=="Yes"){	
	    imageCalculator("Divide create 32-bit", fret, fret_noise);
	    fret_nobkg = getTitle();
	    rename("fret_nobkg");
	    selectWindow(fret);
	    close();
	    selectWindow(fret_noise);
	    close();
	    imageCalculator("Divide create 32-bit", donnor, donnor_noise);
	    donnor_nobkg = getTitle();
	    rename("donnor_nobkg");
	    selectWindow(donnor);
	    close();
	    selectWindow(donnor_noise);
	    close();
	  }
	  else{  //subtract background in both channels (subtract mean value)
	  	selectWindow(fret);
	    setTool("rectangle");
	    waitForUser("Please select background with rectangular tool. Click OK when done");
 	    getBoundingRect(xmin, ymin, width, height);
 	    getSelectionCoordinates(x, y);
        makeSelection(0, x, y);
	    getStatistics(area,mean_fret);
	    	            	    
		//subtract background by mean value
		run("Select None");    
		print("Substracted BKG value to Fret channels ", mean_fret);
	    selectWindow(fret);
	    run("Subtract...", "value=" + mean_fret);	
	    fret_nobkg = getTitle();
	    rename("fret_nobkg");		
	    selectWindow(donnor);
    	makeSelection(0, x, y);
	    getStatistics(area,mean_donnor);
	    print("Substracted BKG value to Donnor channel: ", mean_donnor);
	    run("Select None");   
    	run("Subtract...", "value=" + mean_donnor);
    	donnor_nobkg = getTitle();	
		rename("donnor_nobkg");
    	
	  }

	  return acpt;  		

}

function objectSegmentation(acpt){

	print("Segmentation...");
	
	// object segmentation by manual or automatic threshold
	Dialog.create("FRET-RATIOMETRICS segmentation");
	Dialog.addMessage("Threshold manually adjusted?");
	Dialog.addChoice("Manual threshold:", newArray("Yes", "No"), "Yes");
	Dialog.show();
	manual_thresh = Dialog.getChoice();

	// object segmentation from acceptor channel vs fret channel
	if (acpt=="Yes"){
		selectWindow("acceptor");
	}
	else{
		selectWindow("fret_nobkg");
	}
		
	run("Duplicate...", "title=tomask");
	run("Median...", "radius=2");
	if (manual_thresh == "Yes"){
		setAutoThreshold();
	   	waitForUser("Select Image -> Adjust -> Threshold..");
	}
	else {
	 	setAutoThreshold("Li dark");
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Li background=Default black"); 	
	}
	run("Analyze Particles...", "size=100-Infinity show=Masks include add");
	roiManager("Select", 0);
	run("Create Mask");
	// devide mask by 255 (0-1)
	run("Divide...", "value=255");
	mask = getTitle();
	rename("mask");

}

function fretAnalysis(title,output_dir) {

	print("FRET analysis...");
	
	// Divide FRET by DONNOR (with no background)
	imageCalculator("Divide create 32-bit stack", "fret_nobkg", "donnor_nobkg");
	rename("Ratio_" + title);
	ratio = getTitle();
	  
	selectWindow(ratio);
	//select ROI and measure inside it
	roiManager("Select", 0);
	run("Set Measurements...", "area mean min integrated display redirect=None decimal=3");
	run("Measure");		

	// Multiply the result by donnor mask in order to get only information inside the cell 
	imageCalculator("Multiply create 32-bit", "mask", ratio);

	//change LUT
	run("royal");
	getStatistics(area, mean, min, max, std, histogram);	   
	//setMinAndMax(mean-3*std, mean+3*std);	  
	run("Enhance Contrast", "saturated=0.35");  
	saveAs("Tiff", output_dir + File.separator + title + "_Ratio.tif");
	run("RGB Color");

	// Save results
	saveResults(output_dir, title);		

	//close and clear all
    run("Close All");
    close("Roi Manager");
    if(isOpen("Results")){
    	list1 = getList("window.titles"); 
     	for (l=0; l<list1.length; l++){ 
   	    	winame = list1[l]; 
   	    	if(winame!="Log"){
     			selectWindow(winame); 
     			run("Close"); 
   	    	}
     	} 	    	
	}
}

// outputs
function saveResults(outputdir, title){

	print("=== Result files saved at ", output_dir);

	roiManager("Save", output_dir + File.separator + title + "_Roi.roi");
	
	saveAs("Results", output_dir + File.separator + title + "_Results.xls");

	saveAs("Tiff", output_dir + File.separator + title + "_RatioRGB.tif");	
}

function merge_excel_files(output_dir){
	setBatchMode(true);
	
	list=getFileList(output_dir);
	L=lengthOf(list);
	first=1;

	for (i=0; i < L; i++){

		if(endsWith(list[i],".xls") && (list[i] != "Final_Results.xls")){
			fname= output_dir+ File.separator + list[i];
			open(fname);
			if(first==1){				
				IJ.renameResults("Total");
				first=0; 	
			}				
			else{
				IJ.renameResults("Results");
				nr = nResults;
				label = newArray(nr); 
				area = newArray(nr); 
				mean = newArray(nr); 
				min = newArray(nr); 
				max = newArray(nr); 
				den = newArray(nr); 
				rawden = newArray(nr); 
				
				for(j=0;j<nr;j++)
				{
					//COPY
				
					label[j]=getResultString("Label",j);
					
					area[j]=getResult("Area",j);
					mean[j]=getResult("Mean",j);
					max[j]=getResult("Min",j);
					min[j]=getResult("Max",j);
					den[j]=getResult("IntDen",j);
					rawden[j]=getResult("RawIntDen",j);
				}
				selectWindow("Results");
				run("Close");
				wait(100);
				
				selectWindow("Total");
				IJ.renameResults("Results"); 
				nt=nResults;
				for(j=0;j<nr;j++)
				{
				//PASTE
					setResult("Label",nt+j,label[j]);
					setResult("Area",nt+j,area[j]);
					setResult("Mean",nt+j,mean[j]);
					setResult("Max",nt+j,max[j]);
					setResult("Min",nt+j,min[j]);
					setResult("IntDen",nt+j,den[j]);
					setResult("RawIntDen",nt+j,rawden[j]);					
				}
				selectWindow("Results");
				IJ.renameResults("Total");
			}
					
		}
	}
	//save
	selectWindow("Total");
	IJ.renameResults("Results");
	saveAs("Results", output_dir + File.separator + "Final_Results.xls");
	setBatchMode(false);
}



