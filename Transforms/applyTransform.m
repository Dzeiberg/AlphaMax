function [preds,aucPU] = applyTransform(X,S,varargin)
    %APPLYTRANSFORM Summary of this function goes here
    %   Detailed explanation goes here
    % Optional Arguments:
    %   - transform : type of transform to apply : {rt: RegressionTree,
    %                                               nn: NeuralNetwork,
    %                                               svm: SVM,
    %                                               none: no transform,
    %                                               optimal: apply all
    %               transforms using the parameters described in
    %               (Zeiberg 2020) then choose one with the highest AUCPU}
    
    % For all other optional arguments, see relevant file
    addpath(fullfile(fileparts(mfilename('fullpath')),"utilities"));
    args= inputParser;
    addOptional(args, 'transform','nn');
    % NeuralNetwork.m arguments
    addOptional(args,'hidden_layer_sizes', [5,5]);
    % transform_svm.m arguments
    addOptional(args,'polynomialOrder', 1);
    addOptional(args,'kfoldvalue', 10);
    addOptional(args,'applyPlattCorrection',false)
    addOptional(args','SVMlightpath',fullfile(stdlib.expanduser("~"),"Documents","svm_light"));
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
        [preds,aucPU] = transform_svm(X,S,'parameter',args.polynomialOrder,...
            'kfoldvalue',args.kfoldvalue,...
            'applyPlattCorrection',args.applyPlattCorrection,'SVMlightpath',args.SVMlightpath);
    elseif strcmp(args.transform, 'none')
        aucPU = get_auc_ultra(X,S);
        preds = X;
    elseif strcmp(args.transform, 'optimal')
        warning("This is going to take a while");
        f = waitbar(0, 'finding optimal transform : nn1 : 0/6 complete');
        pause(0.0000001);
        results.nn1 = doNN(X,S,[1,1]);
        f = waitbar(0, 'finding optimal transform : nn5 : 1/6 complete');
        results.nn5 = doNN(X,S,[5,5]);
        f = waitbar(0, 'finding optimal transform : nn25 : 2/6 complete');
        results.nn25 = doNN(X,S,[25,25]);
        f = waitbar(0, 'finding optimal transform : rt : 3/6 complete');
        results.rt = doRT(X,S);
        f = waitbar(0, 'finding optimal transform : svm1 : 4/6 complete');
        results.svm1 = doSVM(X,S,1);
        f = waitbar(0, 'finding optimal transform : svm2 : 5/6 complete');
        results.svm2 = doSVM(X,S,2);
        close(f);
        tnames = fieldnames(results);
        optTransform = "";
        optAUCPU = .49;
        for tnum = 1:numel(tnames)
            if results.(tnames{tnum}).aucPU > optAUCPU
                optTransform = tnames{tnum};
                optAUCPU = results.(tnames{tnum}).aucPU;
            end
        end
        preds = results.(optTransform).preds;
        aucPU = results.(optTransform).aucPU;
    else
        error("Invalid transform, must be one of: {nn,rt,svm,none}");
    end
end

function [res] = doNN(X,S,hidden_layer_sizes)
    mf = @()NeuralNetwork('hidden_layer_sizes',hidden_layer_sizes);
    [res.preds,res.aucPU] = transform_bagging(X,S,mf,...
           'val_frac',.25,...
           'num_bagged_models',100);
end

function [res] = doRT(X,S)
    mf = @()RegressionTree();
    [res.preds,res.aucPU] = transform_bagging(X,S,mf,...
        'val_frac',0,...
        'num_bagged_models',1000);
end

function [res] = doSVM(X,S,order)
    [res.preds,res.aucPU] = transform_svm(X,S,'parameter',order,...
            'kfoldvalue',10,...
            'applyPlattCorrection',true,'SVMlightpath',args.SVMlightpath);
end