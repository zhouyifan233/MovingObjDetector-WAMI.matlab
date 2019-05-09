clear

global numTemplate height width

%% Parameters
image_folder = 'E:/WPAFB-images/testing/';
% image_folder = 'WPAFB-images/png/test/';
AOI_id = '40';
write_output_image = false;
startFrame = 1;    %77
numTemplate = 5;
subtraction_threshold = 5;
winSize = 10;
channels = 4;

%% Area of interest configuration
if strcmp(AOI_id, '01')
    int_centre = [4700, 8050];
    int_size = [600, 600];
elseif strcmp(AOI_id, '02')
    int_centre = [5650, 5300];
    int_size = [600, 600];
elseif strcmp(AOI_id, '03')
    int_centre = [9400, 5950];
    int_size = [600, 600];
elseif strcmp(AOI_id, '34')
    int_centre = [5300, 6300];
    int_size = [1200, 800];
elseif strcmp(AOI_id, '40')
    int_centre = [4850, 8050];
    int_size = [1000, 700];
elseif strcmp(AOI_id, '41')
    int_centre = [6000, 8250];
    int_size = [900, 800];
end
height = int_size(2)*2+1;
width = int_size(1)*2+1;

%% Process starts from here
filenames = dir([image_folder, '*.png']);
winHeight = winSize*2+1;winWidth = winSize*2+1;winDim=[winHeight,winWidth,channels];
load('data/model_predict_position.mat'); 
regression_net = net;
load('data/model_binary_classification.mat');
classification_net = net;
load(['data/TransMatrices_test.mat']);
TransMatrixGlobal = TransMatrix;
load(['data/Groundtruth_test_onlyMoving.mat']);
storage_detections = cell(1, 500);
storage_groundtruth = cell(1, 500);
storage_transformation = cell(1, 500);

templates = cell(numTemplate, 1);
TransMatrixLocal = cell(numTemplate, 1);

% init with 5 frames
for i = 1:numTemplate
    % filename1 = sprintf('frame%06d.png', startFrame+i-1);
    filename1 = filenames(startFrame+i-1).name;
    imgray10 = imread([image_folder filename1]);
    templates{i} = imgray10(int_centre(2)-int_size(2):int_centre(2)+int_size(2), int_centre(1)-int_size(1):int_centre(1)+int_size(1));
    new_int_centre = TransMatrixGlobal{startFrame+i-1} * [int_centre(1); int_centre(2); 1];
    int_centre = round([new_int_centre(1)/new_int_centre(3), new_int_centre(2)/new_int_centre(3)]);
end
for i = 1:numTemplate-1
    TransMatrixLocal{i} = CalculateHomography(templates{i}, templates{numTemplate});
end
TransMatrixLocal{numTemplate} = [1, 0, 0; 0, 1, 0; 0, 0, 1];

% read in #6 and begin iteration
for inx = 1:size(filenames, 1)-startFrame-numTemplate+1
    % filename1 = sprintf('frame%06d.png', startFrame-1+inx+numTemplate);
    filename1 = filenames(startFrame-1+inx+numTemplate).name;
    imgray10 = imread([image_folder filename1]);
    regionX = [int_centre(1)-int_size(1), int_centre(1)+int_size(1)];
    regionY = [int_centre(2)-int_size(2), int_centre(2)+int_size(2)];
    imgray10 = imgray10(regionY(1):regionY(2), regionX(1):regionX(2));
    
    tmp_template = templates{numTemplate};
    timex = cputime;
    [H_t, score] = CalculateHomography(uint8(tmp_template), imgray10);
    disp(['Calculate image registration matrices takes ', num2str(cputime-timex), ' second(s)'])
    for i = 1:numTemplate
        TransMatrixLocal{i} = H_t * TransMatrixLocal{i};
    end
    timex = cputime;
    [background, bgmodels, validArea] = CreateBackground(imgray10, templates, TransMatrixLocal);
    disp(['Background estimation (including image warping) takes ', num2str(cputime-timex), ' second(s)'])
    Groundtruth = GetValidGroundTruth(pos_frame, startFrame+numTemplate-1+inx, validArea, regionX, regionY);
    timex = cputime;
    [detection_centres, valid_imdiffbw_withbg, BGlabels, ConnStats] = BackgroundSubtraction(imgray10, background, bgmodels, validArea, subtraction_threshold);
    disp(['Background subtraction takes ', num2str(cputime-timex), ' second(s)'])
    if ~isempty(detection_centres)
        % Validate background subtraction results by classification CNN.
        timex = cputime;
        CNNDetections = PerformCNNDetections(classification_net, detection_centres, imgray10, bgmodels, winSize, winDim);
        disp(['Detection refinement by classification CNN takes ', num2str(cputime-timex), ' second(s)'])
        % Detection1 includes the accepted detections. Detection2 includes
        % the candidates that should be further processed by the regression
        % CNN.
        [Detection1Stats, Detection2Stats] = AssociateDetection(CNNDetections, BGlabels, ConnStats);
        % perform prediction the positions of moving objects via regression CNN.
        timex = cputime;
        RegressDetectionStats = RegressionDetections(Detection2Stats, BGlabels, ConnStats, imgray10, bgmodels, regression_net);
        disp(['Moving object position prediction by regression CNN takes ', num2str(cputime-timex), ' second(s)'])
        RefinedDetections = ConcludeDetections(Detection1Stats, RegressDetectionStats);
        [precision, recall, falsealarm] = GetPrecisionRecall(RefinedDetections,Groundtruth);
    else
        RefinedDetections = []; stats_CNN = []; CNNDetections = [];
    end
    
    [templates, TransMatrixLocal] = UpdTemplates(templates, TransMatrixLocal, imgray10);
    
    new_int_centre = TransMatrixGlobal{startFrame+inx-1+numTemplate} * [int_centre(1); int_centre(2); 1];
    int_centre = round([new_int_centre(1)/new_int_centre(3), new_int_centre(2)/new_int_centre(3)]);
    
    storage_detections{inx} = RefinedDetections;
    storage_groundtruth{inx} = Groundtruth;
    storage_transformation{inx} = H_t;
    
    if write_output_image
        im1plot = DrawResult(imgray10,valid_imdiffbw_withbg, detection_centres, CNNDetections, RefinedDetections, Groundtruth);
        imwrite(uint8(im1plot), ['output_images/' AOI_id '/', sprintf('frame_%08d.png', startFrame+numTemplate-1+inx)], 'PNG');
    end
    disp(['Frame ', num2str(startFrame-1+inx+numTemplate), ' -- precision: ' num2str(precision) ' -- recall:  ' num2str(recall) ' -- F1 score: ' num2str(2*precision*recall/(precision+recall))]);
    disp('----------------------');
    
end

save(['output_detections/test_set_aoi_' AOI_id '.mat'], 'storage_detections', 'storage_groundtruth', 'storage_transformation');
