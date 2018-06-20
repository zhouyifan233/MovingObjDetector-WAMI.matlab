clear

global numTemplate height width startFrame inx

startFrame = 1;    %77
numTemplate = 3;
winSize = 10;
channels = 3;
subtraction_threshold = 8;

winHeight = winSize*2+1;winWidth = winSize*2+1;winDim=[winHeight,winWidth,channels];
load('data\\model_position_winsize51_singleframe.mat'); position_net51_single = net;
load('data\\model_winsize21_thres8.mat');
load(['data\\TransMatrices_train.mat']);
load(['data\\Groundtruth_onlyMoving_train_speed_1.mat']);
% storage_detections_BS = cell(1, 500);
storage_detections_CNN =  cell(1, 500);
storage_detections = cell(1, 500);
storage_groundtruth = cell(1, 500);

[templates, store_TransMatrix] = Initialisation(TransMatrix);
%% read in #6 and begin iteration
for inx = 1:10
    tic
%     Mat = TransMatrix{startFrame+numTemplate+inx-2};
    filename1 = sprintf('frame%06d.png', startFrame-1+inx+numTemplate);
    imgray10 = imread(['E:\WPAFB-images\training\' filename1]);
    [height, width] = size(imgray10);

    [background, bgmodels, validArea] = CreateBackground(imgray10, templates, store_TransMatrix);
    
    Groundtruth = GetValidGroundTruth(pos_frame, startFrame+numTemplate-1+inx, gather(validArea));

    [detection_centres, stats, valid_imdiffbw_withbg] = BackgroundSubtraction(imgray10, background, validArea, subtraction_threshold);
    
    if ~isempty(detection_centres)
        [CNNDetections,stats_CNN,tmp_idx_map] = PerformCNNDetections(net,detection_centres,stats,imgray10,bgmodels,winSize,winDim);
        
        RefinedDetections = mergeDetections_singleframe(CNNDetections, stats_CNN, imgray10, position_net51_single);
        
        [precision,recall] = GetPrecisionRecall(RefinedDetections,Groundtruth);
    else
        RefinedDetections = [];stats_CNN = [];precision = 0;recall = 0;CNNDetections=[];
    end
    templates = UpdTemplates(templates, imgray10);

    newstore_TransMatrix = cell(numTemplate, 1);
    for j = 1:numTemplate-1
        newstore_TransMatrix{j} = TransMatrix{startFrame+numTemplate-1+inx}*store_TransMatrix{j+1};
    end
    newstore_TransMatrix{numTemplate} = TransMatrix{startFrame+numTemplate-1+inx};
    store_TransMatrix = newstore_TransMatrix;
    
%     storage_detections_BS{inx} = detection_centres;
    storage_detections_CNN{inx} = CNNDetections;
    storage_detections{inx} = RefinedDetections;
    storage_groundtruth{inx} = Groundtruth;
    
%     im1plot = DrawResult(imgray10,valid_imdiffbw_withbg, detection_centres, CNNDetections, RefinedDetections, Groundtruth);
%     figure;imshow(im1plot)
%     save(['F:\WAPAFB_detect_stats_CNN-test\', sprintf('frame_%06d.mat', startFrame+numTemplate-1+inx)], 'stats_CNN');
    toc
    disp(['Frame ', num2str(startFrame+numTemplate-1+inx), ' --- precision: ' num2str(precision) ' ---- recall:  ' num2str(recall)]);
    disp('----------------------');
%     clear imgray10 background bgmodels validArea detection_centres stats valid_imdiffbw_withbg CNNDetections stats_CNN tmp_idx_map RefinedDetections im1plot Groundtruth

end

save('E:\\WPAFB-detections\\WPAFB-train-thres10-MultiframeRefine_2.mat', 'storage_detections', 'storage_detections_CNN', 'storage_groundtruth');
