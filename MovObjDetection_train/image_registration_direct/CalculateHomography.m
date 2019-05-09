function [H, score] = CalculateHomography(img2, img1)
%FINDHOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here
[m, n] = size(img1);
rcontributingMask = zeros(m, n);
rcontributingMask(31:m-30, 31:n-30) = 1;

img1 = medfilt2(img1, [3, 3]);
img2 = medfilt2(img2, [3, 3]);
H = GME_iter(double(img1), double(img2), rcontributingMask, 1);
score = 0;

end

