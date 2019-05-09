function [RegressionDetectionCentre] = GetRegressionResult(reshape_XPred, minx, miny, T)
%GETREGRESSIONRESULT Summary of this function goes here
%   Detailed explanation goes here
RegressionDetectionCentre = [];
Y = max(reshape_XPred(:));
if Y >= T
    [tmpy, tmpx] = find(reshape_XPred == Y);
    Detections = [tmpx+minx, tmpy+miny];
    Y = Y - 0.1;
    while Y > T
        reshape_XPredbw = reshape_XPred >= Y;
        C = bwconncomp(reshape_XPredbw, 8);
        thisObjIdx = C.PixelIdxList;
        for j = 1:C.NumObjects
            [~, tmpidx] = max(reshape_XPred(thisObjIdx{j}));
            [tmpdetectionY, tmpdetectionX] = ind2sub([45, 45], thisObjIdx{j}(tmpidx));
            tmpdetectionX = tmpdetectionX + minx;
            tmpdetectionY = tmpdetectionY + miny;
            if ~ismember([tmpdetectionX, tmpdetectionY], Detections, 'rows')
                Detections = [Detections; [tmpdetectionX, tmpdetectionY]];
            end
        end
        
        Y = Y - 0.1;
    end
    Y = T;
    reshape_XPredbw = reshape_XPred >= Y;
    C = bwconncomp(reshape_XPredbw, 8);
    thisObjIdx = C.PixelIdxList;
    for j = 1:C.NumObjects
        [~, tmpidx] = max(reshape_XPred(thisObjIdx{j}));
        [tmpdetectionY, tmpdetectionX] = ind2sub([45, 45], thisObjIdx{j}(tmpidx));
        tmpdetectionX = tmpdetectionX + minx;
        tmpdetectionY = tmpdetectionY + miny;
        if ~ismember([tmpdetectionX, tmpdetectionY], Detections)
            Detections = [Detections; [tmpdetectionX, tmpdetectionY]];
        end
    end
    RegressionDetectionCentre = [RegressionDetectionCentre; Detections];
end

end

