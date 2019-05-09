function [background, bgmodels, validArea] = CreateBackground(imgray10, templates, TransMatrixLocal)
%CREATEBACKGROUND Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate

bgmodels = zeros(height, width, numTemplate, 'int16');
RA = imref2d([height, width]);

% Propagate Templates
for j = 1:numTemplate
    T1 = projective2d(TransMatrixLocal{j}');
    tmp_warp = imwarp(templates{j}, T1, 'OutputView', RA, 'FillValues', 255);
    bgmodels(:, :, j) = tmp_warp;
end

validArea = GetValidArea(bgmodels);

for j = 1:numTemplate
    diff = int16(imgray10) - bgmodels(:, :, j);
    diff_fil_gpu = imgaussfilt(diff, 6);
    diff_fil_gpu(~validArea) = 0;
    bgmodels(:, :, j) = bgmodels(:, :, j) + diff_fil_gpu;
end

background = median(bgmodels, 3);

end

