classdef (Abstract) Transform
    %DISTANCEMETRIC Base class for one-dimensional, alpha preserving
    %transform
    properties (Abstract)
        model
    end
    methods (Abstract)
        ttrain(x,s)
        tpredict(x)
    end
end