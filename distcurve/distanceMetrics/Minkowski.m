classdef Minkowski < DistanceMetric
    %MINKOWSKI: Implementation of Minakowski Distances (city block,
    %           euclidian, ...)
    
    properties
        order
    end
    
    methods
        function obj = Minkowski(order)
            %MINKOWSKI: Construct an instance of this class
            %   Inputs:
            %       order - int > 0
            %         Examples:
            %         - 1: city block
            %         - 2: euclidian
            
            p = inputParser;
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            addRequired(p,'order',validScalarPosNum);
            parse(p,order);
            obj.order = p.Results.order;
        end
        
        function dist = calc_distance(obj,x1,x2)
            %CALC_DISTANCE: Calculate the distance between two points
            dist = norm(x1-x2,obj.order);
        end
    end
end

