classdef Dataset < handle
    %DATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        X1
        X0
        C
        M
        transforms
        results
    end
    
    methods
        function obj = Dataset(mat)
            %DATASET Construct an instance of this class
            %   Detailed explanation goes here
            obj.X1 = mat.X(mat.y == 1,:);
            obj.X0 = mat.X(mat.y == 0,:);
            % set the component size to 1000 unless the dataset is small
            numP = sum(mat.y);
            if numP < 1000
                obj.C = 100;
            else
                obj.C = 1000;
            end
            % mixture size limited to 10,000
            obj.M = 10000;
        end
        
        function [XC,XM,YM] = getPUSample(obj,varargin)
            % Get a positive and unlabeled sample from the dataset
            % Optional Arguments:
            %   - x1 : positive set to sample from : default raw data
            %   - x0 : negative set to sample from : default raw data
            % parse args
            args = inputParser;
            addOptional(args, 'x1',obj.X1);
            addOptional(args, 'x0',obj.X0);
            parse(args,varargin{:});
            args = args.Results;
            x1 = args.x1;
            x0 = args.x0;
            % Sample positive and unlabeled set
            XCIndices = datasample(1:size(x1,1),obj.C,'Replace',false);
            XC = x1(XCIndices,:);
            % Use the remaining positive instances for the unlabeled set
            MComponentPosIndices = setdiff(1:size(x1,1),XCIndices);
            XM = [x1(MComponentPosIndices,:);x0];
            YM = [ones(size(MComponentPosIndices'));zeros(size(x0,1),1)];
            % If mixture is larger than the limit (10000) proportionally
            % downsample
            if size(YM,1) > obj.M
                f1 = sum(YM)/size(YM,1);
                n1 = round(f1 * obj.M);
                n0 = obj.M - n1;
                numPosOGInMix = size(MComponentPosIndices,1);
                posIndices = datasample(1:numPosOGInMix,n1);
                negIndices = datasample(numPosOGInMix + 1:length(YM),n0);
                XM = XM([posIndices;negIndices'],:);
                YM = YM([posIndices;negIndices']);
            end 
        end
        
        function [] = addTransforms(obj,varargin)
            addpath("Transforms");
            args = inputParser;
            addOptional(args, 'debug',false);
            parse(args,varargin{:});
            args = args.Results;
            X = [obj.X1;obj.X0];
            S = [ones(length(obj.X1),1); zeros(length(obj.X0),1)];
            % Define parameters to all transforms
            if args.debug
                args = {struct('transform','rt')};
             names = {'rt';};
            else
                args = {struct('transform','rt'),...
                     struct('transform','nn','hidden_layer_sizes',[1,1]),...
                     struct('transform','nn','hidden_layer_sizes',[5,5]),...
                     struct('transform','nn','hidden_layer_sizes',[25,25]),...
                     struct('transform','svm','polynomialOrder',1),...
                     struct('transform','svm','polynomialOrder',2)};
                names = {'rt';'nn1';'nn5';'nn25';'svm1';'svm2'};
            end
            
             % apply transforms
             NP = size(obj.X1,1);
            for tnum = 1:length(names)
                [probs,...
                    obj.transforms.(names{tnum}).aucpu] = applyTransform(X,S,args{tnum});
                obj.transforms.(names{tnum}).x1 = probs(1:NP);
                obj.transforms.(names{tnum}).x0 = probs(NP + 1:end);
            end
            % find optimal transform wrt. AUCPU
            maxAUC = 0.5;
            for tnum = 1:length(names)
                if obj.transforms.(names{tnum}).aucpu > maxAUC
                    maxAUC = obj.transforms.(names{tnum}).aucpu;
                    bestTransform = names{tnum};
                end
            end
            obj.transforms.optimal = obj.transforms.(bestTransform);
            obj.transforms.optimal.name = bestTransform;
        end
        
        function [] = runAlgorithms(obj,varargin)
            args = inputParser;
            addOptional(args, 'numReps',10);
            parse(args,varargin{:});
            args = args.Results;
            addpath("distcurve");addpath("alphamax");
            for i = 1:args.numReps
                [xC, xM, yM] = obj.getPUSample(obj.transforms.optimal.x1,...
                    obj.transforms.optimal.x0);
                obj.results.optimal.xC{i} = xC;
                obj.results.optimal.xM{i} = xM;
                obj.results.optimal.yM{i} = yM;
                obj.results.optimal.alpha{i} = sum(yM)/length(yM);
                % Run DistCurve
                [obj.results.optimal.distCurve.alphaHat{i},...
                    obj.results.optimal.distCurve.curve{i},~] = runDistCurve(xM, xC,...
                    'transform','none');
                % Run AlphaMax w/ Inflection Script
                [obj.results.optimal.alphaMaxInflection.alphaHat{i},...
                    obj.results.optimal.alphaMaxInflection.out{i}] = runAlphaMax(xM,xC,...
                    'transform','none','useEstimatorNet',false);
                % Run AlphaMax w/ Estimator Net
                [obj.results.optimal.alphaMaxNet.alphaHat{i},...
                    obj.results.optimal.alphaMaxNet.out{i}] = runAlphaMax(xM,xC,...
                    'transform','none','useEstimatorNet',true);
            end
        end
    end
end

