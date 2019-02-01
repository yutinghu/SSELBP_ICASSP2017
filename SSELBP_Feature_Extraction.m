% Scale selective ELBP(SSELBP) for texture classification
% 2016/06/01
% By Yuting Hu
% Email: huyuting@gatech.edu
% The basic ideas are inspired by scale selective local binary pattern (SSLBP)
% and extended local binary pattern (ELBP). And part of the codes are
% borrowed from the implemementation of median robust extended local binary
% pattern (MRELBP) (link: http://www.cse.oulu.fi/CMV/Downloads).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;

% Add the path of the database
addpath KTH_TIPS

% Define global varibles
global imgPath;          
global sampleNames;      
global sampleIdxClass;   
global allSamples;  
global outexProb;        
global lbpRadius;        
global lbpPoints;        
global numLBPbins;
global lbpMethod;        
global blockSize;        
global numScale;
global numImg;
global numSamples_class;
global numClass;
global scale;
global sigma;
global lbpRadiusSet;

blockSize = 5; % Parameter Initialization
numLBPbins = 0; % Parameter Initialization
lbpPoints = 0; % Parameter Initialization


%% The multi-scale ELBP feature extraction for each scale in scale space
% This is the default parameter setting used in our TIP paper
% It gives fairly good results.
samplingScheme = 'EightSch1';
% Predefine a radius set for calculating local binary patterns
lbpRadiusSet_all = [1 2 3 4 5 6 7 8];
% Select 4 radii from the predefined local radius set
scheme = nchoosek(lbpRadiusSet_all,4);

% For each testing scheme, extract a multi-scale ELBPs at each scale
for schemenum = 1:length(scheme);
    
    lbpRadiusSet = scheme(schemenum,:);
    lbpMethodAll{1} = 'MELBP';
    lbpMethodAll{1} = strcat(lbpMethodAll{1},samplingScheme);

    if strcmp(samplingScheme,'EightSch1')
        % This is the default parameter setting used in our TIP paper
        % It gives fairly good results.
        lbpPointsSet = [8 8 8 8]; 
    elseif strcmp(samplingScheme,'Vary')
        lbpPointsSet = [8 16 24 24];
    else
        error('Not Such Case!');
    end
    
    % *************************************************************************
    % Derive a scale space using Gaussian filters (similiar to that in
    % SSLBP)
    
    % scale pamameter: sigma
    sigma = 2^0.25;
    % For examples, the size of the scale space is set to 4.
    for scale = 1:4

        for idxLBPmethod = 1
            lbpMethod = lbpMethodAll{idxLBPmethod};
            filePathSaved = 'dataset.txt';
            outexProbSet = get_outexProbSet();
            
            for idxLbpRadius = 1 : length(lbpRadiusSet)

                % Generate txt files for image directories
                get_txtfile;
                idxNumProbs = 3;
                outexProb = outexProbSet{idxNumProbs};
                imgPath = 'KTH_TIPS/';
                [subPath,allSamples] = get_subPath(outexProb);
                sampleNamesWithClass = textread(strcat(imgPath,subPath),'%s',allSamples*2+1);
                % Load file names and labels for all images
                sampleNames = sampleNamesWithClass(2:2:end);
                sampleIdxClassStr = sampleNamesWithClass(3:2:end);
                sampleIdxClass = zeros(1,length(sampleIdxClassStr));
                for i = 1 : length(sampleIdxClassStr)
                    sampleIdxClass(i) = str2double(sampleIdxClassStr{i});
                end
                % ==================================================
                % lbpRadius and lbpRadiusPre are sampling radii for
                % calculating ELBP_RD(radial difference)
                lbpRadius = lbpRadiusSet(idxLbpRadius);
                lbpPoints = lbpPointsSet(idxLbpRadius);
                mapping = get_mapping_info(lbpRadius,lbpPoints);
                if idxLbpRadius > 1
                    lbpRadiusPre = lbpRadiusSet(idxLbpRadius-1);
                else
                    lbpRadiusPre = 0;
                end
                
                % Call function SSELBP_KTHTIPS to calculate ELBPs for each
                % (P,R) at each scale
                if strcmp(lbpMethod,'MELBPEightSch1')
                    SSELBP_KTHTIPS(mapping,lbpRadiusPre);
                end

            end

        end % loop idxLBPmethod

    end
    
end

save


%% Texture classification
load matlab
% MRELBPresult stores the results of feature extraction for each testing
% scheme on each (P,R) selection at each scale
addpath MRELBPresult
% We have 100 random partition random partition of training samples and
% testing samples.
% accuracySSELBP represents classification accuracies over 100 trails.
accuracySSELBP = zeros(1,100);
    
for schemenum = 1:length(scheme);

    lbpRadiusSet = scheme(schemenum,:);
    len = length(lbpRadiusSet);
    
    for trails = 1: 100

        numtrain_class = 40;
        numtest_class = numSamples_class-numtrain_class;
        trainnum = numtrain_class*numClass;
        testnum = numtest_class*numClass;
        % The feature dimension for each scale
        fd_scale = numLBPbins*numLBPbins*2;
        % mrelbp_tests and mrelbp_trains store extracted multi-scale
        % features and the class label at each scale for each image
        mrelbp_tests = zeros(testnum,fd_scale*4+1);
        mrelbp_trains = zeros(trainnum,fd_scale*4+1);
        mrelbp_tests_3d = zeros(testnum,fd_scale, 4);
        mrelbp_trains_3d = zeros(trainnum,fd_scale, 4);

        % Distance Matrix
        DM = zeros(testnum,trainnum);
        train_idx = zeros(1,trainnum);
        test_idx = zeros(1,testnum); 

        % Randomly generate training and testing samples
        for j = 1:numClass
            randomidx = randperm(numSamples_class);
            train_idx((j-1)*numtrain_class+1:j*numtrain_class) = randomidx(1:numtrain_class)+numSamples_class*(j-1);
            test_idx((j-1)*numtest_class+1:j*numtest_class) = randomidx(numtrain_class+1:end)+numSamples_class*(j-1);
        end

        for idxLbpRadius = 1:len
            for scale = 1:4
                load(strcat('cfmsWithLabels_KTH-TIPS_', num2str(lbpRadiusSet),lbpMethod,'_P', num2str(lbpPointsSet(idxLbpRadius)),'R',num2str(lbpRadiusSet(idxLbpRadius)),'Scale',num2str(scale),'.mat'));
                mrelbp_trains_3d(:, :, scale) = cfmsWithLabels_LBP(train_idx,1:(end-1));
                mrelbp_tests_3d(:, :, scale) = cfmsWithLabels_LBP(test_idx,1:(end-1));
            end
           
           % Extract scale-selective ELBP features using the maximum pooling across
           % scales
            mrelbp_trains(:,fd_scale*(idxLbpRadius-1)+1:fd_scale*idxLbpRadius) = max(mrelbp_trains_3d, [], 3);
            mrelbp_tests(:,fd_scale*(idxLbpRadius-1)+1:fd_scale*idxLbpRadius) = max(mrelbp_tests_3d, [], 3 );
           % Keep the class label for each image
            mrelbp_trains(:,end) = cfmsWithLabels_LBP(train_idx,end);
            mrelbp_tests(:,end) = cfmsWithLabels_LBP(test_idx,end);
        end

        for j=1:testnum
            test = mrelbp_tests(j,1:end-1);
            % Calculate a distance matrix based on the chi-sqaure distance
            DM(j,:) = distMATChiSquare(mrelbp_trains(:,1:end-1),test)';
        end


        % Record the classification accuracy for each trial
        accuracySSELBP(trails) = ClassifyOnNN(DM,mrelbp_trains(:,end),mrelbp_tests(:,end));
%         accuracySSELBP(trails)
%         schemenum
    end

    % Calculate the mean classification accuracy over 100 trails
    CA_mean(schemenum) = mean(accuracySSELBP);
    
end

save