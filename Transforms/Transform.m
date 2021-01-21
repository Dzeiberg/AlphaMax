classdef (Abstract) Transform
    %DISTANCEMETRIC Base class for one-dimensional, alpha preserving
    %transform
    
    methods (Abstract)
        train(x,s)
        predict(x)
    end
end