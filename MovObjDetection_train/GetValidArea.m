function [validArea] = GetValidArea(bgmodels)
%GETVALIDAREA Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate

validArea = false(height, width);
validArea(10:height-10, 10:width-10) = true;
% validArea_template = false(height, width, 3, 'gpuArray');

for j = 1:numTemplate
    blackwhiteArea = bgmodels(:, :, j) == 255;
    ConnCell = bwconncomp(blackwhiteArea, 8);
    for i = 1:ConnCell.NumObjects
        if numel(ConnCell.PixelIdxList{i}) > 1000
            validArea(ConnCell.PixelIdxList{i}) = false;
        end
    end
end

validArea = imerode(validArea, strel('square', 8));

end

