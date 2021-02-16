addpath("syntheticDataGeneration/");
addpath("alphamax");
ss = SyntheticSampler("data/syntheticParameters.mat");
[p,u,alpha] = ss.getSample();
[alphaHat,out] = runAlphaMax(u,p,'transform','none','useEstimatorNet',true);