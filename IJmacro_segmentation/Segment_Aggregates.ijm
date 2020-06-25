//	Author: Rafael Camacho
//  github: camachodejay
//  date:   2019 - 07 - 03
//  current address: Centre for cellular imaging - Göteborgs universitet

/*
 * The purpose of this macro is to go open a folder and iterate over all .nd2 files,
 * once it loads a file then it segments the aggretates in the image and stores
 * the cropped ROI of each aggregate, data outside of the ROI is set to zero
 */

macro "Segment_Aggregates" {

	// as user for the directory containing .nd2 files
	data_dir = getDirectory("Choose a Directory");
	
	// list all files in the parent directory
	list = getFileList(data_dir);

	// iterate over each file and run calculations
	for (i=0; i<list.length; i++) {
		
		if (endsWith(list[i], ".nd2")){
		// if the file is a .nd2 file then segment
			fullPath = data_dir + list[i];
			print(fullPath);
			runSingleFile(fullPath, data_dir);
			
			
		}else {
		// else skip the file
			print("skipping");
			
		}
	}

}

function runSingleFile(fullPath, data_dir) {
	// run segmentation strategy on a single file

	// find name of the file
	idx1 = lastIndexOf(fullPath, File.separator);
	idx2 = lastIndexOf(fullPath, ".nd2");
	name = substring(fullPath, idx1+1, idx2);
	print(name);
	
	// open file
	run("Bio-Formats Importer", "open=" + fullPath + " autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	main_image = getTitle();

	// max projection between red and green channels
	max_im = "max_proj";
	selectWindow(main_image);
	run("Z Project...", "projection=[Max Intensity]");
	rename(max_im);

	// gaussian blur	
	gauss_sigma = 1;
	// min area of the aggregate, to remove small detections 
	min_area = 1000;
	test_name = segmentCluster(max_im, gauss_sigma, min_area);
	selectWindow(test_name);
	seg_image = max_im + "_segmentation";
	rename(max_im + "_segmentation");

	// crop each roi and save in separate tiff for later
	roi_dir = data_dir + name + "_ROIs/";
	File.makeDirectory(roi_dir);
	cropROIs(main_image, seg_image, roi_dir);
	run("Close All");
	
}

function segmentCluster(input_im, gauss_sigma, min_area) {
	
	//min_area = 200; //pixels
	doWatershed = false;
	showOverlay = true;
	
	// check that we got single image
	selectWindow(input_im);
	nr_slices = nSlices;
	if (nSlices > 1) {
		exit("error on segmentCluster, built to handle single images no stacks")
	}

	// duplicate image to work on it
	seg_image = "Cluster_segmentation";
	run("Duplicate...", "title=["+ seg_image +"]");

	
	// enhance local contrast and do gaussian blur
	selectWindow(seg_image);
	run("Normalize Local Contrast", "block_radius_x=200 block_radius_y=200 standard_deviations=2 center stretch");
	run("Gaussian Blur...", "sigma=" + gauss_sigma + " stack");
	// threshold image	
	setAutoThreshold("Li dark");
	run("Convert to Mask", "method=Li background=Dark calculate black");
	// remove small objects
	run("Area Opening", "pixel=" + min_area);
	
	// close and rename
	selectWindow(seg_image);
	close();
	selectWindow(seg_image + "-areaOpen");
	rename(seg_image);

	// if I want to implement watershed then go
	if (doWatershed) {
		run("Distance Transform Watershed", "distances=[Borgefors (3,4)] output=[16 bits] normalize dynamic=1 connectivity=4");
		setThreshold(1, 65000);
		run("Convert to Mask");
		selectWindow(seg_image);
		close();
		selectWindow(seg_image + "-dist-watershed");
		rename(seg_image);
		
	}

	// if I want to overlay results for user to see then go
	if (showOverlay) {
		overlayBW(input_im, seg_image);
		
	}else {
		/*
		selectWindow(input_im);
		close();
		*/
	}

	return seg_image;
	
}


function overlayBW(im_title, bw_title) {
	// place the edges of the BW image (binary segmentation), into the target image im_title

	selectWindow(bw_title);
	run("Analyze Particles...", "size=1-Infinity pixel show=Nothing clear add");
	selectWindow(im_title);
	roiManager("Show All without labels");
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.8");
	selectWindow(bw_title);
	
	// clear ROIs from test image
	roiManager("reset");
	selectWindow("ROI Manager");
	run("Close");
	selectWindow(im_title);
	
	
}

function cropROIs(im_title, bw_title, roi_dir) {
	// take a main image (im_title), and a binary segmentation (bw_title), define the ROIs, 
	// crop them and then store them as separated tifs. Files are stored at the roi_dir

	selectWindow(bw_title);
	run("Analyze Particles...", "size=1-Infinity pixel show=Nothing clear add");
	selectWindow(im_title);
	roiManager("Show All without labels");
	
		for (idx=0; idx<roiManager("count"); ++idx) {
		
			selectWindow(im_title);
			roiManager("Select", idx);
			run("Duplicate...", "duplicate channels=1");
			//roiManager("Show None");
			roiName = "ROI_" + idx + "_green";
			rename(roiName);
			run("Clear Outside");
			saveAs("Tiff", roi_dir + roiName);
			run("Close");
			
			selectWindow(im_title);
			run("Duplicate...", "duplicate channels=2");
			//roiManager("Show None");
			roiName = "ROI_" + idx + "_red";
			rename(roiName);
			run("Clear Outside");
			saveAs("Tiff", roi_dir + roiName);
			run("Close");
	}
	
	
}