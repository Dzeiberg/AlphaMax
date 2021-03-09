addpath("syntheticDataGeneration/");
addpath("Transforms");
ss = SyntheticSampler("data/syntheticParameters.mat");
[p,u,alpha] = ss.getSample();
X = [p;u];
s = [ones(length(p),1);zeros(length(u),1)];
[score, aucPU] = applyTransform(X,s,'transform','svm');