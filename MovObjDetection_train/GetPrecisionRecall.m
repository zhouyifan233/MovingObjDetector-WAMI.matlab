function [precision,recall] = GetPrecisionRecall(RefinedDetections,Groundtruth)
%GETPRECISIONRECALL Summary of this function goes here
%   Detailed explanation goes here

if ~isempty(RefinedDetections)
%     GroundtruthUsage = false(size(Groundtruth, 1), 1);
%     DetectionsAssign = zeros(size(Groundtruth, 1), 1);
    
    [idx1, dist1] = knnsearch(RefinedDetections, Groundtruth, 'K', 5);
    dist_idx1 = dist1 <= 10;
    dist_logical1 = zeros(size(dist1,1), 5);
    dist_logical1(dist_idx1) = idx1(dist_idx1);
    fn = sum(dist_logical1(:,1) == 0);
    
    GroundtruthUsage = false(size(Groundtruth, 1), 1);
    [idx2, dist2] = knnsearch(Groundtruth, RefinedDetections, 'K', 5);
    dist_idx2 = dist2 <= 10;
    dist_logical2 = zeros(size(dist2,1), 5);
    dist_logical2(dist_idx2) = idx2(dist_idx2);
    tp = 0;
    for j = 1:size(dist2, 1)
        for k = 1:5
            assignedIdx = dist_logical2(j, k);
            if assignedIdx == 0
                break;
            elseif assignedIdx > 0 && ~GroundtruthUsage(assignedIdx)
                tp = tp + 1;
                GroundtruthUsage(assignedIdx) = true;
                break;
            end
        end
    end
    
    fp = size(RefinedDetections,1) - tp;
    
    precision = tp/(tp+fp);
    recall = tp/(tp+fn);
    
end

