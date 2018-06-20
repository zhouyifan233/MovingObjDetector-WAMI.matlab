function [RefinedDetections] = mergeDetections(CNNDetections, stats_CNN, imgray10, bgmodels, position_net)
%MERGEDETECTIONS Summary of this function goes here
%   Detailed explanation goes here
global height width numTemplate
winSize = 22;
RefinedDetections = [];
img_tminus1 = gather(bgmodels(:, :, numTemplate));
img_tminus2 = gather(bgmodels(:, :, numTemplate-1));
[height, width] = size(imgray10);
processedDetections = false(size(CNNDetections, 1),1);
for CNNDetect_idx = 1:size(CNNDetections, 1)
    if ~processedDetections(CNNDetect_idx)
        centerX0 = CNNDetections(CNNDetect_idx, 1);
        centerY0 = CNNDetections(CNNDetect_idx, 2);
        [neiIdx, neiDist] = knnsearch(CNNDetections, [centerX0,centerY0], 'K', 10);
        neiIdx = neiIdx(neiDist <= 15 & (~processedDetections(neiIdx))');
        processedDetections(neiIdx) = 1;
        
        if size(neiIdx, 2) == 1
            RefinedDetections = [RefinedDetections; [centerX0,centerY0]];
        elseif size(neiIdx, 2) > 1
            neiCenters = round(CNNDetections(neiIdx, :));
            meaCenter = round(mean(neiCenters, 1));
            
            minx = round(meaCenter(1)-winSize);
            maxx = round(meaCenter(1)+winSize);
            miny = round(meaCenter(2)-winSize);
            maxy = round(meaCenter(2)+winSize);
            
            if minx > 0 && miny > 0 && maxx <= width && maxy <= height
                
                X_position = zeros(45, 45, 3, 1);
                X_position(:, :, 1, 1) = imgray10(miny:maxy, minx:maxx);
                X_position(:, :, 2, 1) = img_tminus1(miny:maxy, minx:maxx);
                X_position(:, :, 3, 1) = img_tminus2(miny:maxy, minx:maxx);
                
                XPred = predict(position_net,X_position, 'MiniBatchSize', 1000, 'ExecutionEnvironment', 'gpu');
                reshape_XPred = double(imresize(reshape(XPred, [7, 7]), [45, 45]));
                validNei_inx_local = {};
                validNei_val_local = [];
                for i = 1:size(neiIdx, 2)
                    thisNeiPixels_inx_global = stats_CNN(neiIdx(i)).PixelIdxList;
                    [tmpY, tmpX] = ind2sub([height, width], thisNeiPixels_inx_global);
                    tmpY = tmpY-miny+1;tmpX = tmpX-minx+1;new_tmpY=tmpY(tmpY>0&tmpX>0&tmpY<=45&tmpX<=45);new_tmpX=tmpX(tmpY>0&tmpX>0&tmpY<=45&tmpX<=45);
                    thisNeiPixels_inx_local = sub2ind([45, 45], new_tmpY, new_tmpX);
                    thisNeiPixels_val_local = reshape_XPred(thisNeiPixels_inx_local);
                    if sum(thisNeiPixels_val_local > 0.5) > 0
                        validNei_inx_local = [validNei_inx_local, [thisNeiPixels_inx_local]];
                        validNei_val_local = [validNei_val_local; max(thisNeiPixels_val_local(thisNeiPixels_val_local>0.5))];
                    end
                end
                if size(validNei_inx_local,1)>0
                    tmp_thr = max(min(validNei_val_local)-0.15, 0.5);
                    reshape_XPred_bw = reshape_XPred >= tmp_thr;
                    [bwL, bwLnum] = bwlabel(reshape_XPred_bw, 4);
                    validL = [];
                    addDetections = [];
                    for i=1:size(validNei_inx_local, 2)
                        validL = [validL; bwL(validNei_inx_local{i})];
                    end
                    validL = unique(validL);
                    for L_i = 1:size(validL, 1)
                        if validL(L_i) > 0
                            [tmpY, tmpX] = find(bwL==validL(L_i));
                            addDetections = [addDetections; [mean(minx+tmpX), mean(miny+tmpY)]];
                        end
                    end
                    RefinedDetections = [RefinedDetections; addDetections];
                end
                
            end
        end
    end
end

end

