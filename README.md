# Moving Object detection in Wide-Area Motion Imagery (matlab version)
Moving object detection (vehicles) for WAMI images

Algorithm was trained using WPAFB dataset: https://www.sdms.afrl.af.mil/index.php?collection=wpafb2009

Decompress WPAFB dataset under "WPAFB-images\ntf\"

Run "WPAFB-images\nitf2png.m" to convert ntf images to png images.

Run "run_area_of_interest_test_set.m" to process the experiments.

This code is the implementation for our accepted paper in 22nd International Conference on Information Fusion 2019. It should produce exact results as the paper. Python implementations will be released as well. 

AOI_id can be "01, 02, 03, 34, 40, 41". Details can be found in the paper.

