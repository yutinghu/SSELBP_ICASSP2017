function SSELBP_KTHTIPS(mapping,lbpRadiusPre)

% global allTrainSamples;
global allSamples;
global texDatabaseName;
global lbpPoints;
global numLBPbins;
global imgPath;
global sampleNames;
global sampleIdxClass;
global lbpRadius;
global outexProb;
global lbpMethod;
global scale
global sigma
global lbpRadiusSet

% the number of all the models to be learnt
numImages = allSamples;

% To generate pattern histograms, multiple combination methods are used
% here.
% The pattern histogram for all images
% ELBP_NI: histogram of neighbor index
% ELBP_RD: histogram of radial difference
% ELBP_CINI, ELBP_CIRD, MRELBP_CINIRD: joint histograms
cfmsWithLabels_MRELBP_NI = zeros(numImages,(numLBPbins+1));
cfmsWithLabels_MRELBP_RD = zeros(numImages,(numLBPbins+1));
cfmsWithLabels_MRELBP_NIRD = zeros(numImages,(numLBPbins*numLBPbins+1));
cfmsWithLabels_MRELBP_CINI = zeros(numImages,(numLBPbins*2+1));
cfmsWithLabels_MRELBP_CIRD = zeros(numImages,(numLBPbins*2+1));
cfmsWithLabels_MRELBP_CINIRD = zeros(numImages,(numLBPbins*numLBPbins*2+1));

for idxSample = 1 : allSamples
    
    texSampNo = idxSample;
    Joint_CIRD = zeros(numLBPbins,2);
    Joint_CINI = zeros(numLBPbins,2);
    Joint_CINIRD = zeros(numLBPbins,numLBPbins,2);
    Joint_NIRD = zeros(numLBPbins,numLBPbins);
    disp(strcat('sample',sampleNames{texSampNo},'_finished'));
%     filePath = strcat(imgPath,'images\',sampleNames{texSampNo});
    filePath = sampleNames{texSampNo};
    filePath(filePath=='\') = '/';
    img = imread(filePath);
    
    % image sample preprocessing
    img = samp_prepro(img);
    
    % scale space
    sigma = 2^0.25;
    for gaussianconv = 1:(scale-1)
        h = fspecial('gaussian', 2*ceil(2*sigma)+1, sigma);
        img = imfilter(img,h);
    end
    
    % *********************************************************************
%     imgExt = padarray(img,[1 1],'symmetric','both');
%     imgblks = im2col(imgExt,[3 3],'sliding');
%     a = median(imgblks);
%     b = reshape(a,size(img));
%       b = img;
    % *********************************************************************
    
    CImg = img(lbpRadius+1:end-lbpRadius,lbpRadius+1:end-lbpRadius);
    CImg = CImg(:) - mean(CImg(:));
    CImg(CImg >= 0) = 2;
    CImg(CImg < 0) = 1;
%     if lbpRadius == 1
    if lbpRadiusPre == 0
%         filWin = 3;
%         halfWin = (filWin-1)/2;
%         imgExt = padarray(img,[halfWin halfWin],'symmetric','both');
%         imgblks = im2col(imgExt,[filWin filWin],'sliding');
%         % each column of imgblks represent a feature vector
%         imgMedian = median(imgblks);
%         imgCurr = reshape(imgMedian,size(img));
%         imgCurr = img;
        NILBPImage = NILBP_Image(img,lbpPoints,mapping,'image');
        NILBPImage = NILBPImage(:);
        histNI = hist(NILBPImage,0:(numLBPbins-1));
        NILBPImage = NILBPImage + 1;
        
        RDLBPImage = RDLBP_Image_SmallestRadiusOnly(img,img,lbpRadius,lbpPoints,mapping,'image');
        RDLBPImage = RDLBPImage(:);
        histRD = hist(RDLBPImage,0:(numLBPbins-1));
        RDLBPImage = RDLBPImage + 1;
    else
%         if mod(lbpRadius,2) == 0
%             filWin = lbpRadius + 1;
%         else
%             filWin = lbpRadius;
%         end
%         halfWin = (filWin-1)/2;
%         imgExt = padarray(img,[halfWin halfWin],'symmetric','both');
%         imgblks = im2col(imgExt,[filWin filWin],'sliding');
%         % each column of imgblks represents a feature vector
%         imgMedian = median(imgblks);
%         imgCurr = reshape(imgMedian,size(img));
%         imgCurr = img;
        NILBPImage = NILBP_Image(img,lbpPoints,mapping,'image');
        NILBPImage = NILBPImage(:);
        histNI = hist(NILBPImage,0:(numLBPbins-1));
        NILBPImage = NILBPImage + 1;
        
%         if mod(lbpRadiusPre,2) == 0
%             filWin = lbpRadiusPre + 1;
%         else
%             filWin = lbpRadiusPre;
%         end
        
%         halfWin = (filWin-1)/2;
%         imgExt = padarray(img,[halfWin halfWin],'symmetric','both');
%         imgblks = im2col(imgExt,[filWin filWin],'sliding');
%         imgMedian = median(imgblks);
%         imgPre = reshape(imgMedian,size(img));
%         imgPre = img;
        
        RDLBPImage = NewRDLBP_Image(img,img,lbpRadius,lbpRadiusPre,lbpPoints,mapping,'image');
        RDLBPImage = RDLBPImage(:);
        histRD = hist(RDLBPImage,0:(numLBPbins-1));
        RDLBPImage = RDLBPImage + 1; 
    end
    
    cfmsWithLabels_MRELBP_NI(idxSample,:) = [histNI sampleIdxClass(idxSample)];
    cfmsWithLabels_MRELBP_RD(idxSample,:) = [histRD sampleIdxClass(idxSample)];
    
    for i = 1 : length(NILBPImage)
        Joint_CINI(NILBPImage(i),CImg(i)) = Joint_CINI(NILBPImage(i),CImg(i)) + 1;
        Joint_CIRD(RDLBPImage(i),CImg(i)) = Joint_CIRD(RDLBPImage(i),CImg(i)) + 1;
        Joint_NIRD(NILBPImage(i),RDLBPImage(i)) = ...
            Joint_NIRD(NILBPImage(i),RDLBPImage(i)) + 1;
        Joint_CINIRD(NILBPImage(i),RDLBPImage(i),CImg(i)) = ...
            Joint_CINIRD(NILBPImage(i),RDLBPImage(i),CImg(i)) + 1;
    end
    cfmsWithLabels_MRELBP_CINI(idxSample,:) = [Joint_CINI(:)' sampleIdxClass(idxSample)];
    cfmsWithLabels_MRELBP_CIRD(idxSample,:) = [Joint_CIRD(:)' sampleIdxClass(idxSample)];
    cfmsWithLabels_MRELBP_NIRD(idxSample,:) = [Joint_NIRD(:)' sampleIdxClass(idxSample)];
    cfmsWithLabels_MRELBP_CINIRD(idxSample,:) = [Joint_CINIRD(:)' sampleIdxClass(idxSample)];
end


%% Save the results of ELBP feature extraction;
resultSaveFolder = strcat('./','MRELBPresult');
if ~isdir(resultSaveFolder)
    mkdir(resultSaveFolder);
end
resultPath = strcat(resultSaveFolder,'/cfmsWithLabels_',texDatabaseName,outexProb);


cfmsWithLabels_LBP = cfmsWithLabels_MRELBP_CINIRD;
save(strcat(resultPath,'_',num2str(lbpRadiusSet),lbpMethod,'_P', num2str(lbpPoints),'R',num2str(lbpRadius),'Scale',num2str(scale),'.mat'),'cfmsWithLabels_LBP');
cfmsWithLabels_LBP = [cfmsWithLabels_MRELBP_CINI(:,1:end-1) cfmsWithLabels_MRELBP_CIRD];
save(strcat(resultPath,'_',num2str(lbpRadiusSet),lbpMethod,'_CINICIRD','_P', num2str(lbpPoints),'R',num2str(lbpRadius),'Scale',num2str(scale),'.mat'),'cfmsWithLabels_LBP');
cfmsWithLabels_LBP = cfmsWithLabels_MRELBP_NIRD;
save(strcat(resultPath,'_',num2str(lbpRadiusSet),lbpMethod,'_NIRD','_P', num2str(lbpPoints),'R',num2str(lbpRadius),'Scale',num2str(scale),'.mat'),'cfmsWithLabels_LBP');
cfmsWithLabels_LBP = cfmsWithLabels_MRELBP_NI;
save(strcat(resultPath,'_',num2str(lbpRadiusSet),lbpMethod,'_NI','_P', num2str(lbpPoints),'R',num2str(lbpRadius),'Scale',num2str(scale),'.mat'),'cfmsWithLabels_LBP');
cfmsWithLabels_LBP = cfmsWithLabels_MRELBP_RD;
save(strcat(resultPath,'_',num2str(lbpRadiusSet),lbpMethod,'_RD','_P', num2str(lbpPoints),'R',num2str(lbpRadius),'Scale',num2str(scale),'.mat'),'cfmsWithLabels_LBP');

clear cfmsWithLabels_MRELBP_NI;
clear cfmsWithLabels_MRELBP_RD;
clear cfmsWithLabels_MRELBP_CINI;
clear cfmsWithLabels_MRELBP_CIRD;
clear cfmsWithLabels_MRELBP_CINIRD;
clear cfmsWithLabels_LBP;

end % end of the function












