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
            addOptional(args,'num_bagged_models', 100);
            addOptional(args,'hidden_layer_sizes', [5,5]);
            parse(args,varargin{:});
            obj.args = args.Results;
            obj.constructNetwork();
        end
        
        function [] = constructNetwork(obj)
            obj.net = feedforwardnet(obj.hidden_layer_sizes,'trainrp');
            for l = 1:length(obj.args.hidden_layer_sizes)
                obj.net.layers{l}.transferFcn = 'tansig';
            end
            obj.net.trainParam.epochs = 500;
            obj.net.trainParam.show = NaN;
            obj.net.trainParam.showWindow = false;
            obj.net.trainParam.max_fail = 25;
            obj.net.divideFcn = 'divideind';

        end
        function [] = train(obj,x,s, train_indices, val_indices)
            obj.net.divideParam.trainInd = train_indices;
            obj.net.divideParam.valInd = val_indices;
            obj.net.divideParam.testInd = [];
            obj.net = train(obj.net, x, s);
        end
        
        function [preds] = predict(x)
            preds = predict(obj.net,x);
        end
    end
end

