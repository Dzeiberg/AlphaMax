classdef (Abstract) DistanceMetric
    %DISTANCEMETRIC Base class for metrics used by makeDistanceCurve
    
    methods (Abstract)
        calc_distance(x1,x2)
    end
    
    methods
        function distances = get_distances(componentInstance, mixtureSamples)
            assert((size(componentInstance,1) == 1) & (size(componentInstance,2) == size(mixtureSamples,2)), 'Invalid input sizes; size(X)=(1,n), size(Y)=(m2,n)');
            m2 = size(mixtureSamples,1);
            distances = zeros(m2,1);
            for j = 1:m2
               distances(j) = calc_distance(componentInstance,mixtureSamples(j));
            end
        end
    end
end

