classdef NeuralNetwork < Transform
    %NEURALNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        args
        net
        
    end
    
    methods
        function obj = NeuralNetwork(varargin)
            %NEURALNETWORK : MLP for predicting p/u label
            args= inputParser;
            addOptional(args,'hidden_layer_sizes', [5,5]);
            parse(args,varargin{:});
            obj.args = args.Results;
            obj.net = obj.constructNetwork();
        end
        
        function [net] = constructNetwork(obj)
            net = patternnet(obj.args.hidden_layer_sizes);
%             net = feedforwardnet(obj.args.hidden_layer_sizes,'trainrp');
%             for l = 1:length(obj.args.hidden_layer_sizes)
%                 net.layers{l}.transferFcn = 'tansig';
%             end
            net.trainParam.epochs = 500;
            net.trainParam.show = NaN;
            net.trainParam.showWindow = false;
            net.trainParam.max_fail = 25;
            net.divideFcn = 'divideind';
              

        end
        function [net] = ttrain(obj,x,s, train_indices, val_indices)
            obj.net.divideParam.trainInd = train_indices;
            obj.net.divideParam.valInd = val_indices;
            obj.net.divideParam.testInd = [];
            net = train(obj.net, x', s');
        end
        
        function [preds] = tpredict(obj,x)
            preds = obj.net(x');%predict(obj.net,x);
        end
    end
end

