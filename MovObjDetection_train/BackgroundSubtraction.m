function [detection_centres, stats, valid_imdiffbw_withbg] = BackgroundSubtraction(imgray10, background, validArea, subtraction_threshold)
%BACKGROUNDSUBTRACTION Summary of this function goes here
%   Detailed explanation goes here
% imgray10 = double(imgray10);
% background = double(background);

imdiff_withbg = abs(double(imgray10) - double(background));
imdiffbw_withbg = false(size(imgray10));
imdiffbw_withbg(imdiff_withbg >= subtraction_threshold) = 1;
imdiffbw_withbg = imopen(imdiffbw_withbg, strel('square', 3));
valid_imdiffbw_withbg = imdiffbw_withbg & validArea;

[bwL, bwLnum] = bwlabel(valid_imdiffbw_withbg, 4);
valid_imdiffbw_withbg = gather(valid_imdiffbw_withbg);

if bwLnum <= 150000
    stats = regionprops(bwL,'PixelIdxList', 'Area', 'BoundingBox', 'Centroid');
    
    detection_centres = zeros(100000, 2);
    remainInd = zeros(100000, 1);
    stats_cnt = 1;
    for statsInd = 1:size(stats, 1)
        pixelInx = stats(statsInd, 1).PixelIdxList;
        areaSize = stats(statsInd, 1).Area;
        if areaSize <= 3000
            remainInd(stats_cnt, 1) = statsInd;
            detection_centres(stats_cnt, :) = stats(statsInd, 1).Centroid;
            stats_cnt = stats_cnt + 1;
        end
    end
    remainInd = remainInd(1:stats_cnt-1, :);
    detection_centres = detection_centres(1:stats_cnt-1, :);
    stats = stats(remainInd, 1);
else
    detection_centres=[];stats=[];
end

end

