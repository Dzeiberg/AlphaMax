addpath("syntheticDataGeneration/");
addpath("distcurve");
% ss = SyntheticSampler("data/syntheticParameters.mat");
% [p,u,alpha] = ss.getSample();
p = zeros(10,1);
u = 1:100;
u = u';
[alphaHat,curve, aucPU] = runDistCurve(u,p,'transform','none');
figure;plot(curve)