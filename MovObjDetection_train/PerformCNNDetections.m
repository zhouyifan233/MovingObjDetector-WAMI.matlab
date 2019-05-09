function CNNDetections = PerformCNNDetections(net,detection_centres,imgray10,bgmodels,winSize,winDim)
%CNNDETECTIONS Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate
winHeight=winDim(1);winWidth=winDim(2);channels=winDim(3);
% tmp_idx_map = zeros(height, width);
det_cnt = 1;
img_tminus1 = bgmodels(:, :, numTemplate);
img_tminus2 = bgmodels(:, :, numTemplate-1);
img_tminus3 = bgmodels(:, :, numTemplate-2);
positive_dataset = zeros(winHeight, winWidth, channels, 100000, 'uint8');
detection_refined = zeros(100000, 2);
remainInd = false(size(detection_centres, 1),1);
for preDetectInx = 1:size(detection_centres, 1)
    minx = round(detection_centres(preDetectInx, 1)-winSize);
    maxx = round(detection_centres(preDetectInx, 1)+winSize);
    miny = round(detection_centres(preDetectInx, 2)-winSize);
    maxy = round(detection_centres(preDetectInx, 2)+winSize);
    if minx>0 && miny>0 && maxx<=width && maxy<=height
        remainInd(preDetectInx) = true;
        positive_dataset(:, :, 1, det_cnt) = imgray10(miny:maxy, minx:maxx);
        positive_dataset(:, :, 2, det_cnt) = img_tminus1(miny:maxy, minx:maxx);
        positive_dataset(:, :, 3, det_cnt) = img_tminus2(miny:maxy, minx:maxx);
        positive_dataset(:, :, 4, det_cnt) = img_tminus3(miny:maxy, minx:maxx);
        detection_refined(det_cnt, :) = detection_centres(preDetectInx, :);
        det_cnt = det_cnt + 1;
    end
end

% stats = stats(remainInd, 1);
positive_dataset = positive_dataset(:, :, :, 1:det_cnt-1);
detection_refined = detection_refined(1:det_cnt-1, :);

[X_Pred, score] = classify(net, positive_dataset, 'MiniBatchSize', 5000, 'ExecutionEnvironment', 'auto');
CNNDetections_idx = find(score(:, 1) >= 0.8);
CNNDetections = detection_refined(CNNDetections_idx, :);

end

