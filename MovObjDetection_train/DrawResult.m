function [im1plot] = DrawResult(imgray10,valid_imdiffbw_withbg, detection_centres, CNNDetections, RefinedDetections, Groundtruth)
%DRAWRESULT Summary of this function goes here
%   Detailed explanation goes here
global numTemplate startFrame inx

% background subtraction results.
im1plot = drawBSDetections(valid_imdiffbw_withbg, imgray10);

% Show first CNN detections
if ~isempty(CNNDetections)
    im1plot = drawCNNDetections(im1plot, CNNDetections);
end

% Use second CNN to refine detections
if ~isempty(RefinedDetections)
    im1plot = drawRefinedDetections(im1plot, RefinedDetections);
end

% Groundtruth
if ~isempty(Groundtruth)
    im1plot = drawGroundtruth(im1plot, Groundtruth);
end

end

