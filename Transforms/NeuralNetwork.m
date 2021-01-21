classdef NeuralNetwork < Transform
    %NEURALNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        args
        model
        
    end
    
    methods
        function obj = NeuralNetwork(varargin)
            %NEURALNETWORK : MLP for predicting p/u label
            args= inputParser;
            addOptional(args,'hidden_layer_sizes', [5,5]);
            parse(args,varargin{:});
            obj.args = args.Results;
            obj.model = obj.constructNetwork();
        end
        
        function [net] = constructNetwork(obj)
            net = patternnet(obj.args.hidden_layer_sizes);
            net.trainParam.epochs = 500;
            net.trainParam.show = NaN;
            net.trainParam.showWindow = false;
            net.trainParam.max_fail = 25;
            net.divideFcn = 'divideind';
              

        end
        function [model] = ttrain(obj,x,s, train_indices, val_indices)
            % Return a trained neural network
            obj.model.divideParam.trainInd = train_indices;
            obj.model.divideParam.valInd = val_indices;
            obj.model.divideParam.testInd = [];
            model= train(obj.model, x', s');
        end
        
        function [preds] = tpredict(obj,x)
            % return the probability that each point came from the positive
            % (v. unlabeled) set
            preds = obj.model(x');
        end
    end
end

