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
            model = fitctree(x,s);
        end
        
        function [preds] = tpredict(obj,x)
            [~,score,~,~] = predict(obj.model,x);
            preds = score(:,2);
        end
    end
end