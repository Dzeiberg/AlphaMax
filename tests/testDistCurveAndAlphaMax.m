% Load samples from the UCI gas dataset that have already been transformed
addpath(genpath('.'));
load("data/uci_ml_datasets/gas.mat");
XM=ds.instances{1}.optimal.xm;
XC=ds.instances{1}.optimal.xc;
trueClassPrior=sum(ds.instances{1}.yM)/size(ds.instances{1}.yM,1);

% Run AlphaMax
%addpath("alphamax");
path_to_alphamax_estimator = "alphamax/estimators/alphamaxEstimator.mat";
[alphaMax_pred,alphaMax_out] = runAlphaMax(XM,XC,'transform','rt','useEstimatorNet',false,...
     'estimator',path_to_alphamax_estimator);

%Run DistCurve
addpath("distcurve");
path_to_distcurve_estimator = "distcurve/estimator/network.mat";
[distCurve_pred,distCurve_curve, distCurve_aucPU] = runDistCurve(XM,XC,'transform','rt',...
    'estimator',path_to_distcurve_estimator);

disp(strcat("True Class Prior: ",num2str(trueClassPrior),"; AlphaMax Estimate: ",num2str(alphaMax_pred),"; DistCurve Estimate: ",num2str(distCurve_pred)))
figure
plot(distCurve_curve)
hold on
xline(100*distCurve_pred,'-','DistCurve Prediction')
xline(100*trueClassPrior,'-','True Class Prior')
legend()
hold off
figure
histogram(XC,'Normalization','probability')
hold on
histogram(XM,'Normalization','probability')
legend