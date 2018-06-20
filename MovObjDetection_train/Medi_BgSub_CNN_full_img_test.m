clear
tic
global numTemplate height width startFrame

testFrame = 20;
startFrame = testFrame-3;    %77
numTemplate = 3;
winSize = 10;
channels = 3;
subtraction_threshold = 8;

winHeight = winSize*2+1;winWidth = winSize*2+1;winDim=[winHeight,winWidth,channels];
load('E:\\WPAFB-Models\\Vehicle-Position-Regression\\model_position_winsize45.mat'); position_net = net;
load('E:\\WPAFB-Models\\Vehicle-Position-Regression\\model_position_winsize51_singleframe.mat'); position_net51_single = net;
load('E:\\WPAFB-Models\\Vehicle-Binary-Classifier\\model_winsize21_thres8.mat');
load(['data\\TransMatrices_train.mat']);
load(['data\\Groundtruth_onlyMoving_train_speed_1.mat']);

[templates, store_TransMatrix] = Initialisation(TransMatrix);
%% read in #6 and begin iteration

%     Mat = TransMatrix{startFrame+numTemplate+inx-2};
filename1 = sprintf('frame%06d.png', startFrame+numTemplate);
imgray10 = imread(['E:\WPAFB-images\training\' filename1]);
% imgray10 = imresize(imgray10, 0.75);
[height, width] = size(imgray10);

[background, bgmodels, validArea] = CreateBackground(imgray10, templates, store_TransMatrix);

Groundtruth = GetValidGroundTruth(pos_frame, startFrame+numTemplate, gather(validArea));

[detection_centres, stats, valid_imdiffbw_withbg] = BackgroundSubtraction(imgray10, background, validArea, subtraction_threshold);

if ~isempty(detection_centres)
    [CNNDetections,stats_CNN,tmp_idx_map] = PerformCNNDetections(net,detection_centres,stats,imgray10,bgmodels,background,winSize,winDim);
    
    RefinedDetections = mergeDetections_singleframe(CNNDetections, stats_CNN, imgray10, position_net51_single);
    
%     RefinedDetections = mergeDetections(CNNDetections, stats_CNN, imgray10, bgmodels, position_net);
    
    [precision,recall] = GetPrecisionRecall(RefinedDetections,Groundtruth);
else
    RefinedDetections = [];stats_CNN = [];precision = 0;recall = 0;CNNDetections=[];
end
im1plot = DrawResult(imgray10,valid_imdiffbw_withbg, detection_centres, CNNDetections, RefinedDetections, Groundtruth);
figure;imshow(im1plot);
toc
disp(['Frame ', num2str(startFrame+numTemplate), ' --- precision: ' num2str(precision) ' ---- recall:  ' num2str(recall)]);
disp('----------------------');

