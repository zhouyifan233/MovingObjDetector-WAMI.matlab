function [outputImg] = drawGroundtruth(inputImg, Groundtruth)
%DRAWGROUNDTRUTH Summary of this function goes here
%   Detailed explanation goes here
Groundtruth_circle = [Groundtruth, 2*ones(size(Groundtruth, 1), 1)];
outputImg = insertShape(inputImg, 'Circle', Groundtruth_circle, 'color', 'yellow');
end

