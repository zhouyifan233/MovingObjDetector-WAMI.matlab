function [ templates, TransMatrix ] = UpdTemplates( templates, TransMatrix, imgray10 )
%UPDTEMPLATES Summary of this function goes here
%   Detailed explanation goes here
% Update background model
global numTemplate
templates(1:numTemplate-1) = templates(2:numTemplate);
% templatesUpdTime(:, :, 1:numTemplate-1) = templatesUpdTime(:, :, 2:numTemplate);
templates{numTemplate} = imgray10;

TransMatrix(1:numTemplate-1) = TransMatrix(2:numTemplate);
TransMatrix{numTemplate} = [1, 0,0; 0, 1, 0; 0, 0, 1];

end

