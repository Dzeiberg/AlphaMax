classdef (Abstract) Transform
    %DISTANCEMETRIC Base class for one-dimensional, alpha preserving
    %transform
    
    methods (Abstract)
        ttrain(x,s)
        tpredict(x)
    end
end