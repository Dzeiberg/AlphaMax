function [score,aucPU] = transform_svm(X,s,varargin) 
    addpath("Transforms/SVM");
    %transform_svm : Fit an polynomial kernel svm using 10-fold
    %cross validation, then optionally use Platt's correction (1999) to
    %transform scores to posterior probabilities
    % Required Arguments
    %   - x : n x d : d-dimensional features for n instances
    %   - s : n x 1 : P/U labels for n instances
    %
    % Optional Arguments
    %   - kernel : default 1 : 1 -> polynomial kernel; 2 -> RBF kernel
    %
    %   - parameter : default 1 : the polynomial order if using polynomial
    %                             kernel
    %
    %   - kfoldvalue : default 10 : number of folds to use in
    %                               k-fold CV
    %
    %   - applyPlattCorrection : logical : whether to transform SVM scores
    %                                      to posterior probabilities
    %
    %   - pos_weight : default 1 : whether to use balanced training,
    %                              equally weighing positives and unlabeled
    %                              points
    %
    % Return Values:
    %
    %   - score : n x 1 : probability instance from positive (v. unlabeled)
    %                    class
    %
    %   - aucPU : double : Positive/Unlabeled AUC of the transform
    addpath("Transforms/utilities");
    args= inputParser;
    addOptional(args,'kernel', 1);
    addOptional(args,'parameter',2);
    addOptional(args,'kfoldvalue', 10);
    addOptional(args,'applyPlattCorrection',true)
    addOptional(args,'SVMlightpath','~/Documents/research/software/svm_light');
    addOptional(args,'do_normalize',1);
    addOptional(args,'pos_weight',1);
    parse(args,varargin{:});
    args = args.Results;
    % predictions (cummulative)
    pX = zeros(size(X, 1), 1);
    % k-fold cross-validation
    b = n_fold(size(X, 1), args.kfoldvalue);
    % run training and testing
    for i = 1 : args.kfoldvalue
        q = setdiff(1 : size(X, 1), b{i});
        Xtr = X(q, :);
        ytr = s(q, :);
        Xts = X(b{i}, :);
        % normalize training and test sets
        if args.do_normalize == 1
            [mn, sd, Xtr] = normalize(Xtr, [], []);
            [~, ~, Xts] = normalize(Xts, mn, sd);
        end
        p = SVMprediction([Xtr ytr], Xts, args);
        pX(b{i}) = p;  % add predictions
    end
    % Platt's correction to get posterior probabilities
    w = weighted_logreg(pX, s, ones(size(s, 1), 1));
    score = 1 ./ (1 + exp(-w(1) - w(2) * pX));

    aucPU = get_auc_ultra(score, s);
    
end