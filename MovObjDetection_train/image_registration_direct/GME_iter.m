function [ A, IterNum ] = GME_iter( imgray1, imgray2, contributingMask, nlevel )
%IMAGEESTIMATION Summary of this function goes here
%   Detailed explanation goes here
%threshold the error squared and then only use the pixels that are below the error threshold
step = 2;
IterNum = zeros(nlevel, 1);
[Height, Width] = size(imgray1);
%init A
TransVector = [0, 0, 1, 0, 0, 1, 0, 0];

for i = nlevel:-1:1
    if(1)
        TransVector(1) = TransVector(1) * step;
        TransVector(2) = TransVector(2) * step;
    end
    %double the size of image
    currentHeight = round(Height/(step^(i-1)));
    currentWidth = round(Width/(step^(i-1)));
    %the learning rate changes related to size of the image
    img1 = imresize(imgray1, [currentHeight, currentWidth]);
    img2 = imresize(imgray2, [currentHeight, currentWidth]);

    contributingMask = logical(imresize(contributingMask, [currentHeight, currentWidth], 'nearest'));
    
    %do Warp
    RA = imref2d([size(img1,1), size(img1,2)]);
    A = [TransVector(3), TransVector(4), TransVector(1); TransVector(5), TransVector(6),...
        TransVector(2); TransVector(7), TransVector(8), 1];
    T = projective2d(A');
    warp_img2 = imwarp(img2, T, 'OutputView', RA);
    
    [Gx, Gy] = calcGradient(img1);
    Gx = Gx(contributingMask);
    Gy = Gy(contributingMask);
    [TransVector, IterNum(i, 1)] = GME_iter_inner(double(img1), double(img2), currentWidth, currentHeight, Gx, Gy, contributingMask, TransVector);
%     fprintf('Image Pyramid Level: %d, Number of Iterations: %d \n', i, IterNum(i, 1));
end

A = [TransVector(3), TransVector(4), TransVector(1); TransVector(5), TransVector(6),...
        TransVector(2); TransVector(7), TransVector(8), 1];

end

