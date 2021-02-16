function [ensemble_prediction, aucPU] = transform_bagging(X,S,modelfactory,varargin)
    % BAGGING : make out-of-bag predictions on all instances in X0 and X1
    % Required Arguments
    %   - X : n x d double : matrix of d-dimensional features for n
    %       instances
    %
    %   - S : n x 1 int32 : matrix of P/U labels for each instance
    %
    %   - modelfactory : function handle returning an instance of a
    %                  subclass of Tranform
    %         examples:
    %               - @()NeuralNetwork('hidden_layer_sizes',[32,32]);
    %               - @()RegressionTree('
                            
    %
    % Optional Arguments
    %   - val_frac : double in [0,1] : fraction of training data to use for
    %              validation
    %
    % Return Values
    %
    %   - ensemble_predictions : n x 1 double : probability each instance 
    %                            from positive (v. unlabeled) class
    %   - aucPU : double : Positive/Unlabeled AUC of the transform
%     addpath("utilities/");
    addpath(fullfile(fileparts(mfilename('fullpath')),"/utilities"))
    args= inputParser;
    function [res] = isvalidTransform(t)
        m = t();
        res = strcmp(superclasses(m),"Transform");
    end
    assert(isvalidTransform(modelfactory));
    addOptional(args,'val_frac',.25, @(x) x >= 0 && x <= 1);
    addOptional(args,'num_bagged_models', 100);
    parse(args,varargin{:});
    % Accumulate Predictions across all the bags for each point
    preds = zeros(size(X,1),1);
    numPreds = zeros(size(X,1),1);
    for baggingNum = 1 : args.Results.num_bagged_models
        [inBagData, inBagLabels, trainIndices, valIndices, outOfBagData, outOfBagIndices] = getBaggingData(X, S,args.Results.val_frac);
        model = modelfactory();
        trainedModel = model.ttrain(inBagData, inBagLabels, trainIndices, valIndices);
        model.model = trainedModel;
        [outOfBagPreds] = model.tpredict(outOfBagData);
        for i = 1:length(outOfBagIndices)
            idx= outOfBagIndices(i);
            preds(idx) = preds(idx) + outOfBagPreds(i);
            numPreds(idx) = numPreds(idx) + 1;
        end
    end
    % There is ~ 3.844e-42 percent chance a point doesn't end up in any bag
    % in that case, guess 0
    for i = 1:size(numPreds,1)
        if numPreds(i) == 0
            preds(i) = 0;
            numPreds(i) = 1;
        end
    end
    ensemble_prediction = (preds ./ numPreds);
    aucPU = get_auc_ultra(ensemble_prediction, S);
end