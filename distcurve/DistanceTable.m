classdef DistanceTable
    %DISTANCETABLE Store the distance between pairs of points from the
    %component sample and mixture sample

    properties
        distance_metric
        table
    end
    
    methods
        function obj = DistanceTable(numComponentSamples, numMixtureSamples,distance_metric)
            %DISTANCETABLE Construct an instance of this class
            % Manages the storage and calculation of distances between
            % pairs of component and mixture points. Improves speed by
            % storing distances that have already been calculated.
            % Syntax: [distanceTable] = DistanceTable(numComponentSamples,
            % numMixtureSamples,distance_metric);
            %
            % Required Arguments:
            %   numComponentSamples - int - number of instances in the
            %                               component sample
            %
            %   numMixtureSamples - int - number of instances in the
            %                               mixture sample
            %
            %   distance_metric- Subclass of DistanceMetric- Distance metric object
            %   to use in nearest neighbor calculations
            %
            obj.table = ones(numComponentSamples, numMixtureSamples) * -1;
            obj.distance_metric = distance_metric;
        end
        
        function dist = getDistance(obj,componentSample, componentIndex, mixtureSample, mixtureIndex)
            %GETDISTANCE get the distance between a pair of component and
            %mixture samples, adding the result to the table if it hasn't
            %yet been computed
            %
            % Syntax: [dist] = obj.getDistance(componentSample, componentIndex, mixtureSample, mixtureIndex);
            %
            % Required Arguments:
            %   componentSample - (1 x dim) double - instance from the component sample
            %   componentIndex - int - index of the instance within the component sample
            %   mixtureSample - (1 x dim) double - instance from the mixture sample
            %   componentIndex - int - index of the instance within the mixture sample
            % 
            % Outputs
            %   dist - double - distance between the given pair of points
            if obj.table(componentIndex, mixtureIndex) ~= -1
                dist = obj.table(componentIndex, mixtureIndex);
            else
                dist = obj.distance_metric.calc_distance(componentSample, mixtureSample);
                obj.table(componentIndex, mixtureIndex) = dist;
            end
        end
        
        function [smalledDist,closestMixtureInstance] = getNearestNeighbor(obj, componentInstance, componentIndex, mixtureSamples, mixtureIndices)
            %GETNEARESTNEIGHBOR for a instance from the component sample
            %and a subset of the mixture sample, find the instance in the
            %mixture subset that is closest to the component instance,
            %returning that distance and the index for that nearest mixture
            %instance
            %
            % Required Arguments:
            %   componentInstance - (1 x dim) double - instance from the component sample
            %   componentIndex - int - index of the instance within the component sample
            %   mixtureSamples - (nU x dim) double - subset of the mixture sample
            %   componentIndex - int - indices of the subset within the mixture sample
            %
            % Output
            %   smallestDist - double - the distance between the given component instance and the closest instance from the mixture subset
            %   closestMixtureInstance - int - the index of the nearest mixture instance
            numMixtureSamples = size(mixtureSamples,1);
            distances = zeros(numMixtureSamples, 1);
            for i = 1:numMixtureSamples
               distances(i) = obj.getDistance(componentInstance, componentIndex, mixtureSamples(i), mixtureIndices(i)); 
            end
            [smalledDist, indexInMixtureSubset] = min(distances);
            closestMixtureInstance = mixtureIndices(indexInMixtureSubset);
        end
    end
end

