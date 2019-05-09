function [DetectionCentres] = ConcludeDetections(SingleDetectionStats, RegressDetectionStats)
%CONCLUDEDETECTIONS_V1 Summary of this function goes here
%   Detailed explanation goes here

DetectionCentres = [];

for i = 1:size(SingleDetectionStats, 2)
    DetectionCentres = [DetectionCentres; SingleDetectionStats(i).Centroid];
end

for i = 1:size(RegressDetectionStats, 2)
    DetectionCentres = [DetectionCentres; RegressDetectionStats(i).Centroid];
end


end

