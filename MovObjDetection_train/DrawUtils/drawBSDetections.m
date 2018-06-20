function [im1plot] = drawBSDetections(foreground, im1plot)
%DRAWBSDETECTIONS Summary of this function goes here
%   Detailed explanation goes here

[height, width] = size(im1plot);

im1plot = repmat(im1plot, 1, 1, 3);
% imdiffedge = edge(foreground, 'canny');
[subY, subX] = find(foreground == 1);
if ~isempty(subY) && ~isempty(subX)
    edgeind = sub2ind([height, width, 3], subY, subX, ones(length(subX), 1));
    im1plot(edgeind) = im1plot(edgeind)+100;
    im1plot(edgeind+height*width) = im1plot(edgeind+height*width)-50;
    im1plot(edgeind+height*width*2) = im1plot(edgeind+height*width*2)-50;
    % im1plot = insertShape(im1plot, 'rectangle', [31, 21, 900, 500], 'LineWidth', 1, 'color', 'g');
end
end

