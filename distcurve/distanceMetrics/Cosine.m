classdef Cosine < DistanceMetric
    %Cosine: Implementation of cosine distance
    
    methods
        function obj = Cosine()
            % COSINE: Construct an instance of this class
        end

        function dist = calc_distance(~,x1,x2)
            %CALC_DISTANCE: Calculate the distance between two points
            dist = 1 - (dot(x1,x2)/ (norm(x1,2) * norm(x2,2)));
        end
    end
end