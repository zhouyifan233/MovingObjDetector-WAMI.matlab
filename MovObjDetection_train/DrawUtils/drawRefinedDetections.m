function [outputImg] = drawRefinedDetections(inputImg, RefinedDetections)
%DRAWGROUNDTRUTH Summary of this function goes here
%   Detailed explanation goes here
CNNDetections_circle = [RefinedDetections, 5*ones(size(RefinedDetections, 1), 1)];
outputImg = insertShape(inputImg, 'Circle', CNNDetections_circle, 'color', 'blue');
% for i = 1:size(CNNDetections_idx, 1)
% CNN_idx_strings = cell(size(CNNDetections_idx,1),1);
% for i = 1:size(CNNDetections_idx,1)
%     CNN_idx_strings{i} = num2str(CNNDetections_idx(i));
% end
% outputImg = insertText(outputImg, CNNDetections, CNN_idx_strings);
% end

end

