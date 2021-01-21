classdef RegressionTree < Transform
    %REGRESSIONTREE Bagged Regression Trees for P/U label prediction
    
    properties
        model
        
    end
    
    methods
        function obj = RegressionTree(varargin)
            %REGRESSIONTREE : Bagged Regression Trees for predicting p/u
            %                 label
        end
        
        function [model] = ttrain(~,x,s, ~, ~)
            % fit a regression tree
            model = fitctree(x,s);
        end
        
        function [preds] = tpredict(obj,x)
            % return the probability that each point came from the positive
            % (v. unlabeled) set
            [~,score,~,~] = predict(obj.model,x);
            preds = score(:,2);
        end
    end
end