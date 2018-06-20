function [ templates ] = UpdTemplates( templates, imgray10 )
%UPDTEMPLATES Summary of this function goes here
%   Detailed explanation goes here
% Update background model
global numTemplate
templates(1:numTemplate-1) = templates(2:numTemplate);
% templatesUpdTime(:, :, 1:numTemplate-1) = templatesUpdTime(:, :, 2:numTemplate);
templates{numTemplate} = imgray10;

end

