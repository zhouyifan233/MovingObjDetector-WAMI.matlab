function [detection_centres, valid_imdiffbw_withbg, bwL, ConnStats, imdiffbw_with_minus1] = BackgroundSubtraction(imgray10, background, bgmodels, validArea, subtraction_threshold)
%BACKGROUNDSUBTRACTION Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate

imdiff_withbg = abs(double(imgray10) - double(background));
imdiffbw_withbg = false(size(imgray10));
imdiffbw_withbg(imdiff_withbg >= subtraction_threshold) = true;
imdiffbw_withbg = imdiffbw_withbg & validArea;
valid_imdiffbw_withbg = imopen(imdiffbw_withbg, strel('square', 3));

img_tminus1 = bgmodels(:, :, numTemplate);
imdiff_with_minus1 = abs(double(imgray10) - double(img_tminus1));
imdiffbw_with_minus1 = false(size(imgray10));
imdiffbw_with_minus1(imdiff_with_minus1 >= subtraction_threshold) = true;

bwL0 = bwconncomp(valid_imdiffbw_withbg, 4);
for i = 1:bwL0.NumObjects
    tmpIdx = bwL0.PixelIdxList{i};
    if numel(tmpIdx) >= 2000
        valid_imdiffbw_withbg(tmpIdx) = 0;
    end
end
bwL = bwlabel(valid_imdiffbw_withbg, 4);
ConnStats = regionprops(bwL, 'PixelIdxList', 'Area', 'BoundingBox', 'Centroid');
remainIdx = true(size(ConnStats, 1), 1);
ConnStats = ConnStats(remainIdx, 1);

valid_imdiffbw_withbg = double(valid_imdiffbw_withbg);
ttt = imresize(valid_imdiffbw_withbg, 1/5, 'bilinear');
[centreY0, centreX0] = find(ttt>0);
detection_centres = [(centreX0-1)*5+3, (centreY0-1)*5+3];

end

