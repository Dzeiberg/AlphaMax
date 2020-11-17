classdef Yang < DistanceMetric
    %Yang: Implementation of eq. (4) "Normalized metrics on vectors" from
    %
    % Yang, R.; Jiang, Y.; Mathews, S.; Housworth, E. A.; Hahn,
    % M. W.; and Radivojac, P. 2019. A new class of metrics for
    % learning on real-valued and structured data. Data Min Knowl
    % Disc 33(4):995–1016.
    
    properties
        order
    end
    
    methods
        function obj = Yang(order)
            %Yang: Construct an instance of this class
            %   Inputs:
            %       order: int
            p = inputParser;
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addRequired(p,'order',validScalarPosNum);
            parse(p,order);
            obj.order = p.Results.order;
        end
        
        function dist = calc_distance(obj,x1,x2)
            %CALC_DISTANCE: Calculate the distance between two points
            gteMask = x1 >= x2;
            ltMask = x1 < x2;
            gtSum = sum(x1(:,gteMask) - x2(:,gteMask))^obj.order;
            ltSum = sum(x2(:,ltMask) - x1(:,ltMask))^obj.order;
            unnormalizedDistance = (gtSum + ltSum)^(1/obj.order);
            dist = unnormalizedDistance / sum(max(abs([x1;x2;x1-x2])));
        end
    end
end


