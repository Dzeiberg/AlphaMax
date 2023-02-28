addpath("syntheticDataGeneration/");
addpath("alphamax");
% ss = SyntheticSampler("data/syntheticParameters.mat");
% [p,u,alpha] = ss.getSample();
p = normrnd(3,2,1000,1);
u = [normrnd(-3,2,7000,1);normrnd(3,2,3000,1)];
path_to_estimator = '/home/dz/research/alphamax2/alphamax/estimators/alphamaxEstimator.mat';
[alphaHat,out] = runAlphaMax(u,p,'transform','none','useEstimatorNet',true,...
    'estimator',path_to_estimator);