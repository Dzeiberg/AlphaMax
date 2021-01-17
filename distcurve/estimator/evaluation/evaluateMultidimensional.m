addpath("../");
multidimensional = load("/ssdata/ClassPriorEstimationPrivate/data/multidimensionalData.mat");
dsets = multidimensional.ssdata.ClassPriorEstimationPrivate.data;
setnames = fieldnames(dsets);
clear multidimensional;
net = load("../network.mat");
for dsetnum = 1:numel(setnames)
    distNames = fieldnames(dsets.(setnames{dsetnum}).features);
    y = dsets.(setnames{dsetnum}).labels;
    for distnum = 1:numel(distNames)
        x = dsets.(setnames{dsetnum}).features.(distNames{distnum})(:,1:end-1);
        yhat = predict(net,x);
        ds_ae = abs(yhat - y);
        dsets.(setnames{dsetnum}).abserrs.(distNames{distnum}) = ds_ae;
    end
end

