function [ TransVector, ni ] = GME_iter_inner(rimg1, rimg2, cW, cH, gx, gy, contributingMask, TransVector)
%   Gauss-Newton Method
%
%FINDFLOW Summary of this function goes here
%   Detailed explanation goes here
sign = true;
numIter = 30;
ni = 1;

[tempx, tempy] = meshgrid(1:cW, 1:cH);
tempx = tempx(contributingMask);
tempy = tempy(contributingMask);
img1 = rimg1(contributingMask);
RA = imref2d([size(rimg2,1), size(rimg2,2)]);
while  ni <= numIter && sign
    tempz = TransVector(7).*tempx + TransVector(8).*tempy + 1;
    zx = -( (tempx(:).*(TransVector(1)+TransVector(4).*tempy(:)+TransVector(3).*tempx(:))) ./ tempz(:).^2 .* gx(:) ...
        + (tempx(:).*(TransVector(2)+TransVector(5).*tempx(:)+TransVector(6).*tempy(:))) ./ tempz(:).^2 .*gy(:) );
    zy = -( (tempy(:).*(TransVector(1)+TransVector(4).*tempy(:)+TransVector(3).*tempx(:))) ./ tempz(:).^2 .* gx(:) ...
        + (tempy(:).*(TransVector(2)+TransVector(5).*tempx(:)+TransVector(6).*tempy(:))) ./ tempz(:).^2 .*gy(:) );
    
    tempsg = [(gx(:)./tempz(:))'; (gy(:)./tempz(:))'; (tempx(:).*gx(:)./tempz(:))';...
        (tempy(:).*gx(:)./tempz(:))'; (tempx(:).*gy(:)./tempz(:))';...
        (tempy(:).*gy(:)./tempz(:))'; zx'; zy'];
    sg = tempsg*tempsg';
    
    %do Warp
    A = [TransVector(3), TransVector(4), TransVector(1); TransVector(5), TransVector(6),...
        TransVector(2); TransVector(7), TransVector(8), 1];
    T = projective2d(A');
    img2 = imwarp(rimg2, T, 'OutputView', RA);
    img2 = img2(contributingMask);
    imgdiff = img1 - img2;
    
    mismatchVector = zeros(8, 1);
    mismatchVector1 = gx(:)./tempz(:) .* imgdiff(:);
    mismatchVector(1) = sum(mismatchVector1(:));
    mismatchVector2 = gy(:)./tempz(:) .* imgdiff(:);
    mismatchVector(2) = sum(mismatchVector2(:));
    mismatchVector3 = tempx(:).*gx(:)./tempz(:) .* imgdiff(:);
    mismatchVector(3) = sum(mismatchVector3(:));
    mismatchVector4 = tempy(:).*gx(:)./tempz(:) .* imgdiff(:);
    mismatchVector(4) = sum(mismatchVector4(:));
    mismatchVector5 = tempx(:).*gy(:)./tempz(:) .* imgdiff(:);
    mismatchVector(5) = sum(mismatchVector5(:));
    mismatchVector6 = tempy(:).*gy(:)./tempz(:) .* imgdiff(:);
    mismatchVector(6) = sum(mismatchVector6(:));
    mismatchVector7 = zx .* imgdiff(:);
    mismatchVector(7) = sum(mismatchVector7(:));
    mismatchVector8 = zy .* imgdiff(:);
    mismatchVector(8) = sum(mismatchVector8(:));
    affineLK = -sg \ mismatchVector;
%     if det(sg) <= 1e-10
%        break; 
%     end
    tempA = [affineLK(3)+1, affineLK(4), affineLK(1); ...
        affineLK(5), affineLK(6)+1, affineLK(2); ...
        affineLK(7), affineLK(8), 1] * A;
    oldTransVector = TransVector;
    TransVector = [tempA(1,3), tempA(2,3), tempA(1,1), tempA(1,2), tempA(2,1), tempA(2,2), tempA(3,1), tempA(3,2)];
    
    if abs(TransVector(1)-oldTransVector(1)) <= 0.01 && abs(TransVector(2)-oldTransVector(2)) <= 0.01 &&...
            abs(TransVector(3)-oldTransVector(3)) <= 0.00005 && abs(TransVector(4)-oldTransVector(4)) <= 0.00005 &&...
            abs(TransVector(5)-oldTransVector(5)) <= 0.00005 && abs(TransVector(6)-oldTransVector(6)) <= 0.00005 &&...
            abs(TransVector(7)-oldTransVector(7)) <= 0.00005 && abs(TransVector(8)-oldTransVector(8)) <= 0.00005
        sign = false;
    end
    ni = ni + 1;
end


end

