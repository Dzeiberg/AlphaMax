addpath("syntheticDataGeneration/");
addpath("distcurve");
ss = SyntheticSampler("data/syntheticParameters.mat");
[p,u,alpha] = ss.getSample();
[alphaHat,curve, aucPU] = runDistCurve(u,p,'transform','none');
plot(curve)