classdef (Abstract) DistanceMetric
    %DISTANCEMETRIC Base class for metrics used by makeDistanceCurve
    
    methods (Abstract)
        calc_distance(x1,x2)
    end
end

