# Moving Object detection in Wide-Area Motion Imagery (matlab version)
Moving object detection (vehicles) for WAMI images

This code is the implementation for our paper which has been accpeted in 22nd International Conference on Information Fusion (FUSION) 2019. It should produce exact the same results as the paper.

CNNs were trained using WPAFB dataset: https://www.sdms.afrl.af.mil/index.php?collection=wpafb2009
This code aims for testing the algorithm on WPAFB2009 dataset (the testing set), but also works on other WAMI images/videos (a little modifications should be made).

Python implementations will be released which aims for widely use.

Usage:
Decompress WPAFB dataset under "WPAFB-images\ntf\"
Run "WPAFB-images\nitf2png.m" to convert ntf images to png images.
Run "run_area_of_interest_test_set.m" to process the experiments.
AOI_id can be "01, 02, 03, 34, 40, 41". Details can be found in the paper.
