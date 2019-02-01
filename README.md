# SSELBP_ICASSP2017
Publication: Y. Hu, Z. Long, G. AlRegib, “Scale Selective Extended Local Binary Pattern for Texture Classification,” IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP2017), pp. 1413-1417, 2017.

Bib: 
@inproceedings{hu2017scale,
  title={Scale selective extended local binary pattern for texture classification},
  author={Hu, Yuting and Long, Zhiling and AlRegib, Ghassan},
  booktitle={Acoustics, Speech and Signal Processing (ICASSP), 2017 IEEE International Conference on},
  pages={1413--1417},
  year={2017},
  organization={IEEE}
}

Objective:
The codes are used to verify the performance of the scale selective extended local binary pattern (SSELBP) on the classification accuracy on the database of KTH-TIPS (under KTH_TIPS directory).

Key functions and variables:

----- SSELBP_Feature_Extraction.m
Test the performance of SSELBP on texture classification.
1.	Sampling scheme
a.	Variable “scheme” specifies a set of radii for sampling locations;
b.	Variable “lbpPointsSet” denotes a set of the number of sampling points on each circle;
c.	Variable “mapping” defines a mapping strategy and we use “riu2” here.
2.	Features and labels
a.	Variable “mrelbp_tests”: each row contains the histogram feature and label for each test image; the last column represents class labels;
b.	Variable “mrelbp_trains”: each row contains the histogram feature and label for each training image; the last column represents class labels;
c.	Variable “fd_scale” represents the feature dimension for each scale.

----- SSELBP_KTHTIPS.m
Extract SSELBP features for each predefined (P, R) at each scale in the scale space.

----- distMATChiSquare.m
Calculate a distance matrix based on the chi-square distance.
1.	Distance matrix denoted by variable “DM”.

----- ClassifyOnNN.m
Record the classification accuracy for each trial using nearest neighbor classifier.
1.	Variable “numSamples_class” denotes the number of samples for each class;
2.	Variable “numtrain_class” stands for the number of training samples for each class;
3.	Variable “numClass” defines the number of class;
4.	Variable “train_idx” and “test_idx” define the indices for random partitions between training samples and testing samples
5.	Variable “accuracySSELBP” stores the classification accuracy for 100 partition trails;
6.	Variables “CA_mean” means the average classification for each testing scheme.
