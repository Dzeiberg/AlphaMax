function [preds,aucPU] = applyTransform(X,S,varargin)
    %APPLYTRANSFORM Summary of this function goes here
    %   Detailed explanation goes here
    % Optional Arguments:
    %   - transform : type of transform to apply : {rt: RegressionTree,
    %                                               nn: NeuralNetwork,
    %                                               svm: SVM,
    %                                               none: no transform}
    % For all other optional arguments, see relevant file
    addpath("utilities");
    args= inputParser;
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
    parse(args,varargin{:});
    args = args.Results;
    if strcmp(args.transform, "nn") || strcmp(args.transform, "rt")
       if strcmp(args.transform, "nn")
           mf = @()NeuralNetwork('hidden_layer_sizes',args.hidden_layer_sizes);
           vf = args.val_frac;
       else
           mf = @()RegressionTree();
           vf = 0; % no validation in regression tree training script
       end
       [preds,aucPU] = transform_bagging(X,S,mf,...
           'val_frac',vf,...
           'num_bagged_models',args.num_bagged_models);
    
    elseif strcmp(args.transform, "svm")
        [preds,aucPU] = transform_svm(X,S,'polynomialOrder',args.polynomialOrder,...
            'kfoldvalue',args.kfoldvalue,...
            'applyPlattCorrection',args.applyPlattCorrection);
    elseif strcmp(args.transform, 'none')
        aucPU = get_auc_ultra(X,S);
        preds = X;
    else
        error("Invalid transform, must be one of: {nn,rt,svm,none}");
    end
end

