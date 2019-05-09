function [Groundtruth] = GetValidGroundTruth(pos_frame, FrameIdx, validArea, regionX, regionY)
%GETVALIDGROUNDTRUTH Summary of this function goes here
%   Detailed explanation goes here
global height width

Groundtruth = pos_frame{FrameIdx};
Groundtruth = Groundtruth(:, [4:5, 1]);
Groundtruth(:, 1) = round(Groundtruth(:, 1) - regionX(1));
Groundtruth(:, 2) = round(Groundtruth(:, 2) - regionY(1));
validGT_idx = Groundtruth(:,1) > 0 & Groundtruth(:,2)>0 & Groundtruth(:,1)<width & Groundtruth(:,2)<height;
Groundtruth = Groundtruth(validGT_idx,:);

Groundtruth_map = false(height, width);
Groundtruth_id_map = zeros(height, width);

for i = 1:size(Groundtruth, 1)
    Groundtruth_map(Groundtruth(i, 2), Groundtruth(i, 1)) = true;
    Groundtruth_id_map(Groundtruth(i, 2), Groundtruth(i, 1)) = Groundtruth(i, 3);
end

[GroundtruthY, GroundtruthX] = find(Groundtruth_map & validArea);
Valid_Groundtruth_idx = sub2ind([height, width], GroundtruthY, GroundtruthX);
Groundtruth = [GroundtruthX, GroundtruthY, Groundtruth_id_map(Valid_Groundtruth_idx)];

end

