function [outputImg] = drawCNNDetections(inputImg, CNNDetections)
%DRAWGROUNDTRUTH Summary of this function goes here
%   Detailed explanation goes here
CNNDetections_circle = [CNNDetections, 10*ones(size(CNNDetections, 1), 1)];
outputImg = insertShape(inputImg, 'Circle', CNNDetections_circle, 'color', 'green');
% for i = 1:size(CNNDetections_idx, 1)
% CNN_idx_strings = cell(size(CNNDetections_idx,1),1);
% for i = 1:size(CNNDetections_idx,1)
%     CNN_idx_strings{i} = num2str(CNNDetections_idx(i));
% end
% outputImg = insertText(outputImg, CNNDetections, CNN_idx_strings);
% end

end

