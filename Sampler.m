classdef (Abstract) Sampler < handle
    %SAMPLER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Abstract)
        getSample(obj)
        getLength(obj)
    end
end

