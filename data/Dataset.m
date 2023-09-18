classdef Dataset < handle
    % Object used to evaluate the implementation on multi-dimensional
    % datasets from (Zeiberg et al. 2020). Contains methods to generate the
    % data with the univariate transforms and run the models on this data
    %
    % See buildDatasets.m and evalauteMultidimensionalDatasets.m
    
    properties
        filename
        X1
        X0
        C
        M
        instances
        results
        absErrs
    end
    
    methods
        function obj = Dataset(mat,filename)
            %DATASET Construct an instance of this class
            %   Detailed explanation goes here
            obj.filename = filename;
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
            YM = [ones(size(MComponentPosIndices'));...
                zeros(size(x0,1),1)];
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
        
        function [] = buildPUDatasets(obj,n_instances,varargin)
            % generate n_instances P/U samples and find the optimal
            % univariate transform for each sample
            args = inputParser;
            addOptional(args, 'debug',false);
            parse(args,varargin{:});
            args = args.Results;
            debug = args.debug;
            instances_ = cell(n_instances,1);
            times = 0;
            f = waitbar(0,strcat('building dataset instance: ','0/',num2str(n_instances), '   ---   average time: ',num2str(times/1)));
            for inst_num = 1:n_instances
                tic;
                [XC,XM,yM] = obj.getPUSample();
                X = [XC;XM];
                S = [ones(size(XC,1),1);zeros(size(XM,1),1)];
                inst_results = obj.transform_PU_data(X,S,'debug',debug);
                inst_results.XC = XC;
                inst_results.XM = XM;
                inst_results.yM = yM;
                instances_{inst_num} = inst_results;
                elapsedTime=toc;
                times = times + elapsedTime;
                waitbar(inst_num/n_instances,f,strcat('building dataset instance: ',num2str(inst_num),'/',num2str(n_instances), '   ---   average time: ',num2str(times/inst_num)));
            end
            obj.instances = instances_;
            close(f);
        end
        
        function [] = runAlgorithms(obj,varargin)
            % Run the three methods
            args = inputParser;
            addOptional(args, 'numReps',10);
            parse(args,varargin{:});
            args = args.Results;
            addpath("distcurve");addpath("alphamax");
            for i = 1:args.numReps
                disp([i,args.numReps])
                xC = obj.instances{i}.optimal.xc;
                xM = obj.instances{i}.optimal.xm;
                obj.results.alpha{i} = sum(obj.instances{i}.yM)/length(obj.instances{i}.yM);
                % Run DistCurve
                [obj.results.distCurve.alphaHat{i},...
                    obj.results.distCurve.curve{i},~] = runDistCurve(xM, xC,...
                    'transform','none');
                % Run AlphaMax w/ Inflection Script
                [obj.results.alphaMaxInflection.alphaHat{i},...
                    obj.results.alphaMaxInflection.out{i}] = runAlphaMax(xM,xC,...
                    'transform','none','useEstimatorNet',false);
                % Run AlphaMax w/ Estimator Net
                [obj.results.alphaMaxNet.alphaHat{i},...
                    obj.results.alphaMaxNet.out{i}] = runAlphaMax(xM,xC,...
                    'transform','none','useEstimatorNet',true);
            end
        end
    end
    methods(Static)

        function [inst_results] = transform_PU_data(X,S,varargin)
            % Run univariate transforms on PU Data
            % Required Arguments:
            % - X : (n,d) feature matrix
            % - S : (n,1) PU label matrix with 1 denoting positive and 0 denoting negative
            parser = inputParser;
            addOptional(parser,'debug',false);
            parse(parser,varargin{:});
            args_in = parser.Results;
            addpath("Transforms");
            
            %% Define parameters to all transforms
            if args_in.debug
                args = {struct('transform','svm','polynomialOrder',1)};
                names = {'svm';};
            else
                args = {struct('transform','rt'),...
                     struct('transform','nn','hidden_layer_sizes',[1,1]),...
                     struct('transform','nn','hidden_layer_sizes',[5,5]),...
                     struct('transform','nn','hidden_layer_sizes',[25,25]),...
                     struct('transform','svm','polynomialOrder',1),...
                     struct('transform','svm','polynomialOrder',2)};
                names = {'rt';'nn1';'nn5';'nn25';'svm1';'svm2'};
            end
            inst_results = struct();
             %% apply transforms
             NP = sum(S);
             times = 0;
             f = waitbar(0,strcat('applying transforms: 0/',num2str(length(names)),'    average time: ',num2str(times/1)));
            for tnum = 1:length(names)
                tic;
                name = names{tnum};
                [scores,...
                    inst_results.(name).aucpu] = applyTransform(X,S,args{tnum});
                inst_results.(name).xc = scores(1:NP);
                inst_results.(name).xm = scores(NP + 1:end);
                elapsed = toc;
                times = times + elapsed;
                waitbar(tnum/length(names),f, strcat('applying transforms: ',num2str(tnum),'/',num2str(length(names)),'------- average time: ',num2str(times/tnum)));
            end
            close(f);
            % find optimal transform wrt. AUCPU
            maxAUC = 0.5;
            bestTransform = names{1,1};
            for tnum = 1:length(names)
                if inst_results.(names{tnum}).aucpu > maxAUC
                    maxAUC = inst_results.(names{tnum}).aucpu;
                    bestTransform = names{tnum};
                end
            end
            inst_results.optimal = inst_results.(bestTransform);
            inst_results.optimal.name = bestTransform;
        end
    end
end
