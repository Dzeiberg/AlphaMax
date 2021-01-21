function [prob,aucPU] = transform_svm(x,s,varargin)        
    %transform_svm : Fit an polynomial kernel svm using 10-fold
    %cross validation, then optionally use Platt's correction (1999) to
    %transform scores to posterior probabilities
    % Required Arguments
    %   - x : n x d : d-dimensional features for n instances
    %   - s : n x 1 : P/U labels for n instances
    %
    % Optional Arguments
    %   - polynomialOrder : default 1 : define the order of the
    %                       polynomial kernel
    %   - kfoldvalue : default 10 : number of folds to use in
    %                               k-fold CV
    %   - applyPlattCorrection : logical : whether to transform SVM scores
    %                          to posterior probabilities
    %
    % Return Values:
    %
    %   - prob : n x 1 : probability instance from positive (v. unlabeled)
    %                    class
    %
    %   - aucPU : double : Positive/Unlabeled AUC of the transform
    addpath("utilities");
    args= inputParser;
    addOptional(args,'polynomialOrder', 1);
    addOptional(args,'kfoldvalue', 10);
    addOptional(args,'applyPlattCorrection',true)
    parse(args,varargin{:});
    args = args.Results;
    model = fitcsvm(x,s,'KernelFunction','polynomial',...
        'PolynomialOrder',args.polynomialOrder,...
        'KFold',args.kfoldvalue);
    [labels,~] = kfoldPredict(model);
    if args.applyPlattCorrection
        [prob] = plattCorrect(labels);
    else
        prob = labels;
    end
    aucPU = get_auc_ultra(prob,s);
end