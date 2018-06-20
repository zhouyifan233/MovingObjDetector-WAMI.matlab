function [validArea] = GetValidArea(imgray10, bgmodels)
%GETVALIDAREA Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate
imoperator1 = strel('square', 10);
imoperator2 = strel('square', 3);
validArea = true(height, width, 'gpuArray');
% validArea_template = false(height, width, 3, 'gpuArray');

for j = 1:numTemplate
    blackwhiteArea = (bgmodels(:, :, j)~=255 & bgmodels(:, :, j) ~= 0);
    blackwhiteArea_gpu = gpuArray(blackwhiteArea);
    blackwhiteArea = imclose(blackwhiteArea_gpu, imoperator1);
    validArea_tmp = logical(imopen(blackwhiteArea, imoperator2));
    validArea = validArea & validArea_tmp;
end

% validArea = all(validArea_template, 3);
blackwhiteArea = gpuArray((imgray10~=255 & imgray10 ~= 0));
blackwhiteArea = imclose(blackwhiteArea, imoperator1);
validArea10 = logical(imopen(blackwhiteArea, imoperator2));
validArea = validArea & validArea10;

end

