function [SingleDetectionStats, MultiDetectionStats] = AssociateDetection(CNNcentres, bwlabels, BGresultsStats)
%ASSOCIATEDETECTION Summary of this function goes here
%   Detailed explanation goes here
global height width
SingleDetectionStats = struct('PixelIdxList', [], 'Area', [], 'BoundingBox', [], 'Centroid', []);
MultiDetectionStats = struct('PixelIdxList', [], 'Area', [], 'BoundingBox', [], 'Centroid', []);

CNNmap = false(height, width);
for i = 1:size(CNNcentres, 1)
    x = CNNcentres(i, 1);
    y = CNNcentres(i, 2);
    CNNmap(y-2:y+2, x-2:x+2) = true;
end
CNNmapStats = regionprops(CNNmap, 'PixelIdxList', 'Area', 'BoundingBox', 'Centroid');

AssocMap1 = false(height, width);
AssocMap2 = false(height, width);
cnt1 = 1;
cnt2 = 1;
for i = 1:size(CNNmapStats, 1)
    CNNIdxList = CNNmapStats(i).PixelIdxList;
    CNNArea = CNNmapStats(i).Area;
    BgBGlabels = bwlabels(CNNIdxList);
    BgBGlabels = BgBGlabels(BgBGlabels~=0);
    if sum(BgBGlabels~=0) > 0
        insideBgLabelIdx = unique(BgBGlabels);
        if numel(insideBgLabelIdx) == 1 && CNNArea <= 200
            if CNNArea/BGresultsStats(insideBgLabelIdx).Area >= 0.5
                SingleDetectionStats(cnt1) = BGresultsStats(insideBgLabelIdx);
            else
                SingleDetectionStats(cnt1) = CNNmapStats(i);
            end
            AssocMap1(SingleDetectionStats(cnt1).PixelIdxList) = true;
            cnt1 = cnt1 + 1;
        else
            MultiDetectionStats(cnt2) = CNNmapStats(i);
            AssocMap2(MultiDetectionStats(cnt2).PixelIdxList) = true;
            cnt2 = cnt2 + 1;
        end
    else
        SingleDetectionStats(cnt1) = CNNmapStats(i);
        AssocMap1(SingleDetectionStats(cnt1).PixelIdxList) = true;
        cnt1 = cnt1 + 1;
    end
end

end

