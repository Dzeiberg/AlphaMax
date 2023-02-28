% Load Data
data = load("data/datasets/anuran/anuran.mat");
C = data.C;
M = data.M;
true_class_prior = sum(data.yM) / length(data.yM);

% Run AlphaMax
addpath("alphamax");
path_to_alphamax_estimator = "/home/dz/research/alphamax2/alphamax/estimators/alphamaxEstimator.mat";
[alphaMax_pred,alphaMax_out] = runAlphaMax(M,C,'transform','rt','useEstimatorNet',true,...
     'estimator',path_to_alphamax_estimator);

%Run DistCurve
addpath("distcurve");
path_to_distcurve_estimator = "/home/dz/research/alphamax2/distcurve/estimator/smallnetwork.mat";
[distCurve_pred,distCurve_curve, distCurve_aucPU] = runDistCurve(M,C,'transform','rt',...
    'estimator',path_to_distcurve_estimator);