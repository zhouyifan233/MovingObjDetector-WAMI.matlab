function [Groundtruth] = GetValidGroundTruth(pos_frame, FrameIdx, validArea)
%GETVALIDGROUNDTRUTH Summary of this function goes here
%   Detailed explanation goes here
global height width

Groundtruth = pos_frame{FrameIdx};
Groundtruth = round(Groundtruth(:, 4:5));
validGT_idx = Groundtruth(:,1) > 0 & Groundtruth(:,2)>0 & Groundtruth(:,1)<width & Groundtruth(:,2)<height;
Groundtruth = Groundtruth(validGT_idx,:);
Groundtruth_map = false(height, width);
Groundtruth_idx = sub2ind([height, width], Groundtruth(:, 2), Groundtruth(:, 1));
Groundtruth_map(Groundtruth_idx) = true;
Groundtruth_map = Groundtruth_map & validArea;
[GroundtruthY,GroundtruthX] = find(Groundtruth_map);
Groundtruth = [GroundtruthX, GroundtruthY];

end

