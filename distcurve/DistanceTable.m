classdef DistanceTable
    %DISTANCETABLE Store the distance between pairs of points from the
    %component sample and mixture sample, and calculates the nearest
    %neighbor between a component sample and a subset of mixture points

    properties
        distances
    end
    
    methods
        function obj = DistanceTable(componentSamples, mixtureSamples,distance_metric)
            %DISTANCETABLE Construct an instance of this class
            % Manages the storage and calculation of distances between
            % pairs of component and mixture points. Improves speed by
            % storing distances that have already been calculated.
            % Syntax: [distanceTable] = DistanceTable(numComponentSamples,
            % numMixtureSamples,distance_metric);
            %
            % Required Arguments:
            % componentSamples - (nP x dim) double - component samples
            %
            %   mixtureSamples - (nU x dim) double - mixture samples
            %
            %   distance_metric- Subclass of DistanceMetric- Distance metric object
            %   to use in nearest neighbor calculations
            %
            obj.distances = pdist2(componentSamples, mixtureSamples, distance_metric);
        end
        
        function [smallestDist, index] = getNearestNeighbor(obj, componentIndex, mixtureIndices)
            % GETNEARESTNEIGHBOR Given the index of a compoenent sample of
            % interest and a subset of mixture indices, return the index of
            % the nearest mixture point and the corresponding distance
            %
            % Required Arguments
            % componentIndex - int - index of the component sample of
            % interest
            %
            % mixtureIndices - (n x 1) int - indices of the mixture points
            % you would like to consider when finding the nearest neighbor
            dists = obj.distances(componentIndex,:);
            [smallestDist, minDIdx] = min(dists(mixtureIndices));
            index = mixtureIndices(minDIdx);
        end
    end
end

