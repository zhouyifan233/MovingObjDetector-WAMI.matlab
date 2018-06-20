function [background, bgmodels, validArea] = CreateBackground(imgray10, templates, store_TransMatrix)
%CREATEBACKGROUND Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate
validArea = true(height, width);
bgmodels = zeros(height, width, numTemplate, 'int16');
RA = imref2d([height, width]);
% Propagate Templates

for j = 1:numTemplate
    T1 = projective2d(store_TransMatrix{j}');
    bgmodels(:, :, j) = imwarp(templates{j}, T1, 'OutputView', RA);
end

% validArea_template = false(height, width, 3);
imoperator1 = strel('square', 5);
imoperator2 = strel('square', 10);
for j = 1:numTemplate
    blackwhiteArea = (bgmodels(:, :, j)~=255 & bgmodels(:, :, j) ~= 0);
    blackwhiteArea = imopen(blackwhiteArea, imoperator1);
%     validArea_template(:, :, j) = logical(imopen(blackwhiteArea, imoperator2));
    validArea = validArea & logical(imclose(blackwhiteArea, imoperator2));
end

% validArea = all(validArea_template, 3);
blackwhiteArea = (imgray10~=255 & imgray10 ~= 0);
blackwhiteArea = imopen(blackwhiteArea, imoperator1);
validArea10 = logical(imclose(blackwhiteArea, imoperator2));
validArea = validArea & validArea10;

imgray10 = int16(imgray10);
for j = 1:numTemplate
    diff = imgray10-bgmodels(:, :, j);
    diff_fil = imgaussfilt(diff, 8);
    diff_fil(~validArea) = 0;
    bgmodels(:, :, j) = bgmodels(:, :, j) + diff_fil;
end

background = median(bgmodels, 3);

end

