function [templates, store_TransMatrix] = Initialisation(TransMatrix, imagepath)
%INITIALISATION Summary of this function goes here
%   Detailed explanation goes here
global numTemplate startFrame
templates = cell(numTemplate, 1);
store_TransMatrix = cell(numTemplate, 1);

%% init with 3 frames
for inx = 1:numTemplate
    filename1 = sprintf('frame%06d.png', startFrame+inx-1);
    imgray10 = imread([imagepath filename1]);
%     imgray10 = imresize(imgray10, 0.75);
    templates{inx} = imgray10;
end

%% init #1 #2 #3 #4 #5 to #6 space
for inx = 1:numTemplate
    aa = TransMatrix{startFrame+inx-1};
    for inx1 = inx:numTemplate-1
        a = TransMatrix{startFrame+inx1};
        aa = a*aa;
    end
    store_TransMatrix{inx} = aa;
end

end

