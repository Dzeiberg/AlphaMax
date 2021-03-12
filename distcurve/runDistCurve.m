function [alphaHat, curve, aucPU] = runDistCurve(x,x1,varargin)
%ESTIMATE Estimate the class prior using DistCurve (Zeiberg 2020)
% Required Arguments
%   - x : mixture sample : m x d
%   - x1 : component sample : n x d
%
% Optional Arguments:
%   See the files noted below for details on the optional arguments
addpath(fullfile(fileparts(mfilename('fullpath')),"../Transforms"));
addpath(fullfile(fileparts(mfilename('fullpath')),"../Transforms/utilities"));
addpath(fullfile(fileparts(mfilename('fullpath')),"estimator/"));
args = inputParser;
%% Transform Arguments
% applyTransform.m argument
addOptional(args, 'transform','nn');
% NeuralNetwork.m arguments
addOptional(args,'hidden_layer_sizes', [5,5]);
% transform_svm.m arguments
addOptional(args,'polynomialOrder', 1);
addOptional(args,'kfoldvalue', 10);
addOptional(args,'applyPlattCorrection',true)
% transform_bagging.m arguments
addOptional(args,'val_frac',.25, @(x) x >= 0 && x <= 1);
addOptional(args,'num_bagged_models', 100);
% makeCurves.m arguments
defaultConstructor= @(componentSamples,mixtureSamples) ...
        CurveConstructor(componentSamples,mixtureSamples);
addOptional(args,'constructorHandle',defaultConstructor);
addOptional(args,'quiet', true);
addOptional(args,'savePath','')
% estimator/getEstimate.m argument
addOptional(args,'estimator',"none");
%% Parse Arguments
parse(args,varargin{:});
args = args.Results;
%% Apply One-Dimensional Transform to Data
numU = size(x,1);
X = [x;x1];
S = [zeros(length(x),1);ones(length(x1),1)];
[preds,aucPU]=applyTransform(X,S,...
    'transform',args.transform,...
    'hidden_layer_sizes', args.hidden_layer_sizes,...
    'polynomialOrder',args.polynomialOrder,...
    'kfoldvalue', args.kfoldvalue,...
    'val_frac', args.val_frac,...
    'num_bagged_models', args.num_bagged_models);
% Separate the transformed mixture and positive points
xUnlabeled = preds(1:numU,:);
xPos = preds(numU + 1 : end,:);
%% Make Curve
makeCurveInput.xPos = xPos;
makeCurveInput.xUnlabeled = xUnlabeled;
curve = makeCurves(makeCurveInput,...
    'constructorHandle',args.constructorHandle,...
    'quiet',args.quiet,...
    'savePath',args.savePath);
% curve = curve/sum(curve);
%figure;
%plot(curve)
%% Pass Curve to Class Prior Estimator Network
alphaHat = getDistCurveEstimate(curve,'estimator',args.estimator);
end

