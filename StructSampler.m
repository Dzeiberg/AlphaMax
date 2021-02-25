classdef StructSampler < Sampler & handle
    %StructSampler sample (x,y) values from the struct given by the mat arg
    % Required Arguments:
    % - mat - struct with fields xPos, xUnlabeled
    %           xPos : n x d matrix of features for each positive instance
    %           xUnlabeled : m x d matrix of features for each unlabeled
    %                        instance
    %
    % Optional Arguments:
    %   - nBootstraps : number of bootstrapped samples to return from mat
    %                   default : 0 (just return original data)
    properties
        mat
        n
        d
        m
        nBootstraps
    end
    
    methods
        function obj = StructSampler(mat,varargin)
            %StructSampler Construct an instance of this class
            %   Detailed explanation goes here
            obj.mat = mat;
            [obj.n, obj.d] = size(mat.xPos);
            [obj.m,~] = size(mat.xUnlabeled);
            p= inputParser;
            addOptional(p,'nBootstraps', 0);
            parse(p,varargin{:});
            obj.nBootstraps = p.Results.nBootstraps;
            
        end
        
        function [xP,xU,alpha] = getSample(obj,~)
            % Return dummy for compatability
            alpha = -1;
            if boolean(obj.nBootstraps)
                xP = datasample(obj.mat.xPos,obj.n);
                xU = datasample(obj.mat.xUnlabeled, obj.m);
            else
                xP = obj.mat.xPos;
                xU = obj.mat.xUnlabeled;
            end
        end
        
        function [len] = getLength(obj)
            if obj.nBootstraps == 0
                len = 1;
            else
                len = obj.nBootstraps;
            end
        end
    end
end

