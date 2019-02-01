function sampleIn = samp_prepro(sampleIn)
% image sample preprocessing
sampleIn = double(sampleIn);
sampleIn = sampleIn - mean(sampleIn(:));
% sampleIn = sampleIn / sqrt(mean(mean(sampleIn .^ 2)));
sampleIn = sampleIn / std(sampleIn(:));



