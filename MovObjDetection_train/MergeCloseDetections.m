function [NewDetections] = MergeCloseDetections(OldDetections, DIST)
%MERGERCLOSEDETECTIONS Summary of this function goes here
%   Detailed explanation goes here
NewDetections = [];
[idx, dist] = knnsearch(OldDetections, OldDetections, 'K', 10);
processedDetection = false(size(dist, 1), 1);
for i = 1:size(dist, 1)
    if size(dist, 2) > 1
        if dist(i, 2) <= DIST && ~processedDetection(i)
            mergeDetection = [OldDetections(i,:); OldDetections(idx(i,2),:)];
            processedDetection(i) = true;
            processedDetection(idx(i,2)) = true;
            for j = 3:size(dist,2)
                if dist(i, j) <= DIST && ~processedDetection(idx(i,j))
                    mergeDetection = [mergeDetection; OldDetections(idx(i,j),:)];
                    processedDetection(idx(i,j)) = true;
                end
            end
            NewDetections = [NewDetections; mean(mergeDetection, 1)];
        elseif dist(i, 2) > DIST && ~processedDetection(i)
            NewDetections = [NewDetections; OldDetections(i, :)];
            processedDetection(i) = true;
        end
    else
        NewDetections = [NewDetections; OldDetections(i, :)];
        processedDetection(i) = true;
    end
end

end

