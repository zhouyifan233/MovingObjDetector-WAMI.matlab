function [RefinedDetections2] = mergeDetections_singleframe(CNNDetections, stats_CNN, imgray10, position_net)
%MERGEDETECTIONS Summary of this function goes here
%   Detailed explanation goes here
global height width
winSize = 25;
patchsize = winSize*2+1;
RefinedDetections1 = [];

[height, width] = size(imgray10);
processedDetections = false(size(CNNDetections, 1),1);
for CNNDetect_idx = 1:size(CNNDetections, 1)
    if ~processedDetections(CNNDetect_idx)
        centerX0 = CNNDetections(CNNDetect_idx, 1);
        centerY0 = CNNDetections(CNNDetect_idx, 2);
        [neiIdx, neiDist] = knnsearch(CNNDetections, [centerX0,centerY0], 'K', 10);
        neiIdx = neiIdx(neiDist <= 15 & (~processedDetections(neiIdx))');
        %         processedDetections(CNNDetect_idx) = 1;
        %         processedDetections(neiIdx) = 1;
        
        if size(neiIdx, 2) == 1
            RefinedDetections1 = [RefinedDetections1; [centerX0,centerY0]];
        elseif size(neiIdx, 2) > 1
            neiCenters = round(CNNDetections(neiIdx, :));
            meaCenter = round(mean(neiCenters, 1));
            minx = round(meaCenter(1)-winSize);
            maxx = round(meaCenter(1)+winSize);
            miny = round(meaCenter(2)-winSize);
            maxy = round(meaCenter(2)+winSize);
            
            if minx > 0 && miny > 0 && maxx <= width && maxy <= height
                CandidateArea = zeros(patchsize, patchsize, 'logical');
                for tmpIdx = 1:size(neiIdx, 2)
                    CandidateIdx = stats_CNN(neiIdx(tmpIdx)).PixelIdxList;
                    [CandidateY, CandidateX] = ind2sub([height, width], CandidateIdx);
                    CandidateX = CandidateX - minx + 1;
                    CandidateY = CandidateY - miny + 1;
                    validIdx = CandidateX>0 & CandidateX<patchsize & CandidateY>0 & CandidateY<patchsize;
                    CandidateX = CandidateX(validIdx);
                    CandidateY = CandidateY(validIdx);
                    CandidateIdx = sub2ind([patchsize, patchsize], CandidateY, CandidateX);
                    CandidateArea(CandidateIdx) = 1;
                end
                CandidateArea = imdilate(CandidateArea, strel('square', 3));
                X_position = zeros(patchsize, patchsize, 1, 1);
                X_position(:, :, 1, 1) = imgray10(miny:maxy, minx:maxx);
                
                XPred = predict(position_net,X_position, 'ExecutionEnvironment', 'cpu');
                reshape_XPred = double(imresize(reshape(XPred, [15, 15]), [patchsize, patchsize]));
                assign_map = zeros(patchsize, patchsize);
                assign_count = 0;
                
                for thres = 0.90:-0.1:0.2
                    reshape_XPred_norm_logi = reshape_XPred > thres;
                    [reshape_XPred_norm_logi_label, tmpCount] = bwlabel(reshape_XPred_norm_logi, 4);
                    tmpStats = regionprops(reshape_XPred_norm_logi_label,'PixelIdxList');
                    for tmpIdx = 1:tmpCount
                        if sum(assign_map(tmpStats(tmpIdx).PixelIdxList) ~= 0) == 0
                            assign_count = assign_count + 1;
                            assign_map(tmpStats(tmpIdx).PixelIdxList) = assign_count;
                        end
                    end
                end
                
                assign_map(~CandidateArea) = 0;
                for tmpAssi = 1:assign_count
                    [pointsy, pointsx] = find(assign_map == tmpAssi);
                    if ~isempty(pointsy)
                        RefinedDetections1 = [RefinedDetections1; [minx+round(mean(pointsx)), miny+round(mean(pointsy))]];
                    end
                end
                
            end
        end
    end
end

% RefinedDetections2 = RefinedDetections1;
unprocessed_idx = true(size(RefinedDetections1, 1), 1);
RefinedDetections2 = [];
for rd_idx = 1:size(RefinedDetections1, 1)
    if unprocessed_idx(rd_idx) == true
        X = RefinedDetections1(rd_idx, 1);
        Y = RefinedDetections1(rd_idx, 2);
        [neiIdx, neiDist] = knnsearch(RefinedDetections1, [X,Y], 'K', 50);
        neiIdx = neiIdx(neiDist <= 3 & (unprocessed_idx(neiIdx))');
        unprocessed_idx(neiIdx) = false;
        pointsx = RefinedDetections1(neiIdx, 1);
        pointsy = RefinedDetections1(neiIdx, 2);
        RefinedDetections2 = [RefinedDetections2; [mean(pointsx), mean(pointsy)]];
    end
end

end

