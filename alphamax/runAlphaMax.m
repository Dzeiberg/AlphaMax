function [alphaHat, out] = runAlphaMax(x,x1,varargin)
%ESTIMATE Estimate the class prior using AlphaMax (Jain 2016)
% Required Arguments
%   - x : mixture sample : m x d
%   - x1 : component sample : n x d
%
% Optional Arguments:
%    - useEstimatorNet : default true : use the estimator net (AlphaMaxNet) rather than
%    the inflection script (AlphaMax) to estimate the class prior from the ll curve
%
%   See the files noted below for details on the other optional arguments
addpath(fullfile(fileparts(mfilename('fullpath')),'../Transforms'));
addpath(fullfile(fileparts(mfilename('fullpath')),'estimators/'));
addpath(fullfile(fileparts(mfilename('fullpath')),'Algorithms/'));
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
% estimator/getEstimate.m argument
addOptional(args,'estimator',"/home/dzeiberg/alphamax/alphamax/estimators/alphamaxEstimator.mat");
% choose which estimator to use
addOptional(args,'useEstimatorNet',true);
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
%% Make LL Curve
llcomputer = LLCurve(xUnlabeled, xPos,'parallel',false);
[out.curveAlphas, out.fs, out.compute_llCurve_output] = llcomputer.compute_llCurve();
out.aucPU = aucPU;
%% Get Class Prior Estimate using estimator network
if args.useEstimatorNet
    [alphaHat] = getAlphaMaxEstimate(out.fs,'estimator',args.estimator);
else
    [alphaHat, out.inflectionScriptOutput] = inflectionScript(out.curveAlphas, -out.fs);
end
end
