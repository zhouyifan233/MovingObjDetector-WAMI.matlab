function RegressDetectionStats = RegressionDetections(MultiDetectionStats, BGlabels, BGresultsStats, imgray10, bgmodels, position_net)
%MERGEDETECTIONS Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate
winSize = 22;
T = 0.25;
dim = winSize*2+1;

img_tminus1 = bgmodels(:, :, numTemplate);
img_tminus2 = bgmodels(:, :, numTemplate-1);
img_tminus3 = bgmodels(:, :, numTemplate-2);
[height, width] = size(imgray10);
RegressDetectionStats = struct('PixelIdxList', [], 'Area', [], 'BoundingBox', [], 'Centroid', []);
cnt = 1;

for in = 1:size(MultiDetectionStats, 2)
    BoundingBox = MultiDetectionStats(in).BoundingBox;
    if ~isempty(BoundingBox)
        centre = round(MultiDetectionStats(in).Centroid);
%             if centre(1) > 612 && centre(2) > 678 && centre(1) < 642 && centre(2) < 748
%                disp('!!!');
%             end
        RegressionDetectionCentres = [];
        if BoundingBox(1,3) <= dim/2 && BoundingBox(1,4) <= dim/2
            minx = centre(1)-winSize;
            maxx = centre(1)+winSize;
            miny = centre(2)-winSize;
            maxy = centre(2)+winSize;
            if minx > 0 && miny > 0 && maxx <= width && maxy <= height
                
                X_position = zeros(45, 45, 3, 1);
                X_position(:, :, 1, 1) = imgray10(miny:maxy, minx:maxx);
                X_position(:, :, 2, 1) = img_tminus1(miny:maxy, minx:maxx);
                X_position(:, :, 3, 1) = img_tminus2(miny:maxy, minx:maxx);
                X_position(:, :, 4, 1) = img_tminus3(miny:maxy, minx:maxx);
                XPred = predict(position_net,X_position, 'MiniBatchSize', 10, 'ExecutionEnvironment', 'gpu');
                reshape_XPred = double(imresize(reshape(XPred, [15, 15]), [45, 45]));
                
                RegressionDetectionCentres = GetRegressionResult(reshape_XPred, minx, miny, T);
            end
        else
            start_x = min([round(BoundingBox(1) + winSize/2), centre(1)]);
            end_x = max([BoundingBox(1) + BoundingBox(3), centre(1)]);
            start_y = min([round(BoundingBox(2) + winSize/2), centre(2)]);
            end_y = max([BoundingBox(2) + BoundingBox(4), centre(2)]);
            
            current_x = start_x;
            current_y = start_y;
            while current_x <= end_x
                while current_y <= end_y
                    minx = current_x-winSize;
                    maxx = current_x+winSize;
                    miny = current_y-winSize;
                    maxy = current_y+winSize;
                    if minx > 0 && miny > 0 && maxx <= width && maxy <= height
                        
                        X_position = zeros(45, 45, 3, 1);
                        X_position(:, :, 1, 1) = imgray10(miny:maxy, minx:maxx);
                        X_position(:, :, 2, 1) = img_tminus1(miny:maxy, minx:maxx);
                        X_position(:, :, 3, 1) = img_tminus2(miny:maxy, minx:maxx);
                        X_position(:, :, 4, 1) = img_tminus3(miny:maxy, minx:maxx);
                        XPred = predict(position_net,X_position, 'MiniBatchSize', 1, 'ExecutionEnvironment', 'gpu');
                        reshape_XPred = double(imresize(reshape(XPred, [15, 15]), [45, 45]));
                        
                        tmp_RegressionDetectionCentre = GetRegressionResult(reshape_XPred, minx, miny, T);
                        RegressionDetectionCentres = [RegressionDetectionCentres; tmp_RegressionDetectionCentre];
                    end
                    current_y = current_y + winSize;
                end
                current_y = start_y;
                current_x = current_x + winSize;
            end
            RegressionDetectionCentres = MergeCloseDetections(RegressionDetectionCentres, 5);
        end
        
        % We only keep the regression result within the boundingbox of CNN
        % results
        maxx = BoundingBox(1)+BoundingBox(3);
        maxy = BoundingBox(2)+BoundingBox(4);
        minx = BoundingBox(1);
        miny = BoundingBox(2);
        OldRegressionDetectionCentres = round(RegressionDetectionCentres);
        RegressionDetectionCentres = [];
        for j = 1:size(OldRegressionDetectionCentres, 1)
            if OldRegressionDetectionCentres(j,1)>=minx && OldRegressionDetectionCentres(j,2)>=miny && ...
                    OldRegressionDetectionCentres(j,1)<=maxx && OldRegressionDetectionCentres(j,2)<=maxy
                RegressionDetectionCentres = [RegressionDetectionCentres; OldRegressionDetectionCentres(j, :)];
            end
        end
        
        if size(RegressionDetectionCentres, 1) == 1
            [tmpIdxx, tmpIdxy] = meshgrid(RegressionDetectionCentres(1,1)-2:RegressionDetectionCentres(1,1)+2, RegressionDetectionCentres(1,2)-2:RegressionDetectionCentres(1,2)+2);
            tmpIdx = sub2ind([height, width], tmpIdxy, tmpIdxx);
            BGidx = unique(BGlabels(tmpIdx));
            BGidx = BGidx(BGidx~=0);
            if ~isempty(BGidx)
                RegressDetectionStats(cnt) = BGresultsStats(BGidx(1));
                for j = 2:size(BGidx, 2)
                    RegressDetectionStats(cnt).PixelIdxList = [RegressDetectionStats(cnt).PixelIdxList; BGresultsStats(BGidx(j)).PixelIdxList];
                    RegressDetectionStats(cnt).Area = RegressDetectionStats(cnt).Area + BGresultsStats(BGidx(j)).Area;
                    minx = min([RegressDetectionStats(cnt).BoundingBox(1), BGresultsStats(BGidx(j)).BoundingBox(1)]);
                    miny = min([RegressDetectionStats(cnt).BoundingBox(2), BGresultsStats(BGidx(j)).BoundingBox(2)]);
                    maxx = max([RegressDetectionStats(cnt).BoundingBox(1)+RegressDetectionStats(cnt).BoundingBox(3), BGresultsStats(BGidx(j)).BoundingBox(1)+BGresultsStats(BGidx(j)).BoundingBox(3)]);
                    maxy = max([RegressDetectionStats(cnt).BoundingBox(2)+RegressDetectionStats(cnt).BoundingBox(4), BGresultsStats(BGidx(j)).BoundingBox(2)+BGresultsStats(BGidx(j)).BoundingBox(4)]);
                    RegressDetectionStats(cnt).BoundingBox = [minx, miny, maxx-minx, maxy-miny];
                    RegressDetectionStats(cnt).Centroid = [maxx+minx, maxy+miny] ./ 2;
                end
                cnt = cnt + 1;
            end
        elseif size(RegressionDetectionCentres, 1) > 1
            for j = 1:size(RegressionDetectionCentres, 1)
                RegressDetectionStats(cnt).PixelIdxList = [];
                RegressDetectionStats(cnt).Area = 1;
                RegressDetectionStats(cnt).BoundingBox = [];
                RegressDetectionStats(cnt).Centroid = RegressionDetectionCentres(j, :);
                cnt = cnt + 1;
            end
        end
    end
end

end

