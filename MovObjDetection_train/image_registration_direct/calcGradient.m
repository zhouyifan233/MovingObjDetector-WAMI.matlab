function [Gx, Gy] = calcGradient(imgray)

[m, n] = size(imgray);
fillIm = zeros(m+2, n+2);
fillIm(2:m+1, 2:n+1) = imgray;
dmask = [1 0 -1]/2;
Gx = conv2(fillIm, dmask, 'valid');
Gx = Gx(2:end-1, :);
Gy = conv2(fillIm, dmask.', 'valid');
Gy = Gy(:, 2:end-1);

end