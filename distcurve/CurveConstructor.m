classdef CurveConstructor
   properties
      componentSamples
      mixtureSamples
      numCurvesToAverage
      distanceTable
      percentiles
   end
   
   methods
       function obj = CurveConstructor(componentSamples,mixtureSamples,varargin)
           % CurveConstructor - Given 1-dimensional samples from positive and
           %                     unlabeled set, construct curve used to estimate class
           %                     prior as described in
           % Zeiberg et al. (2020) https://doi.org/10.1609/aaai.v34i29.6151
           %
           % Syntax: [curve] = makeDistanceCurve(positiveSamples, unlabeledSamples)
           %
           % Required Arguments:
           %   componentSamples - (nP x dim) double - component samples
           %
           %   mixtureSamples - (nU x dim) double - mixture samples
           % Optional Arguments:
           %   numCurvesToAverage - int - default: 10 - number of times to repeat 
           %                                            curve construction after which
           %                                            all curves will be averaged
           %
           %   distanceMetric - {'manhattan','euclidian','cosine','yang1','yang2'} or 
           %                     Subclass of distanceMetrics/DistanceMetric - default:
           %                     manhattan - distance metric to use when calculating
           %                     the nearest neighbor
           %
           %   percentiles - vector[int] in range [0,100] - default 0:99 -
           %                       after averaging across all curves, final
           %                       distance curve will be these percentiles
           %                       values of the averages
           %
           %
           %
           % Other m-files required: DistanceTable.m
           % MAT-files required: none
           %
           % See also: distanceMetrics/DistanceMetric.m
           %
           % Author: Daniel Zeiberg
           % Email: zeiberg.d@northeastern.edu
           % Website: dzeiberg.github.io
           % Nov 2020; Last Revision: 16-Nov-2020
           
           % Header template adapted from: 
           % Denis Gilbert (2020). M-file Header Template (https://www.mathworks.com/matlabcentral/fileexchange/4908-m-file-header-template), MATLAB Central File Exchange. Retrieved November 16, 2020.
           % ------------ Parse and Validate Parameters -----
           defaultNumCurvesToAverage = 10;
           defaultDistanceMetric = 'manhattan';
           validDistanceMetrics = {'manhattan','euclidian','cosine','yang1','yang2'};
           defaultPercentiles= 0:99;
           p= inputParser;
           isValidScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
           isSubclass = @(x) strcmp(superclasses(x),"DistanceMetric");
           isValidDistStr = @(x) (any(validatestring(x,validDistanceMetrics)));
           isValidDistanceMetric =  @(x) (ischar(x) && isValidDistStr(x)) || isSubclass(x);
           hasCorrectShape = @(s) size(s,1) >= 1 && size(s,2) >=1;
           areValidPercentiles = @(l) all(l >= 0) && all(l <= 100);
           addRequired(p, "componentSamples", @(s) hasCorrectShape(s));
           addRequired(p, "mixtureSamples", @(s) hasCorrectShape(s));
           addOptional(p,'numCurvesToAverage',defaultNumCurvesToAverage,isValidScalarPosNum);
           addOptional(p,'distanceMetric',defaultDistanceMetric,isValidDistanceMetric);
           addOptional(p, 'percentiles',defaultPercentiles,areValidPercentiles);
           parse(p,componentSamples,mixtureSamples,varargin{:});
           obj.componentSamples = p.Results.componentSamples;
           obj.mixtureSamples = p.Results.mixtureSamples;
           obj.numCurvesToAverage = p.Results.numCurvesToAverage;
           obj.percentiles = p.Results.percentiles;
           assert(size(p.Results.componentSamples,2) == size(p.Results.mixtureSamples,2), "component and mixture samples must have the same dimension at index 2")
           if isSubclass(p.Results.distanceMetric)
               distanceMetric = p.Results.distanceMetric;
           elseif ischar(p.Results.distanceMetric)
               switch p.Results.distanceMetric
                   case "manhattan"
                       distanceMetric = Minkowski(1);
                   case "euclidian"
                       distanceMetric = Minkowski(2);
                   case "cosine"
                       distanceMetric = Cosine();
                   case "yang1"
                       distanceMetric = Yang(1);
                   case "yang2"
                       distanceMetric = Yang(2);
                   otherwise
                       error("Invalid argument for distanceMetric: "+p.Results.distanceMetric);
               end
           else
               error("distanceMetric must be a subclass of DistanceMetric or one of: {manhattan, euclidian, cosine, yang1, yang2");
           end
           obj.distanceTable = DistanceTable(size(componentSamples,1), size(mixtureSamples,1),distanceMetric);
       end
       
       function [curve] = makeSingleCurve(obj)
           nComp = size(obj.componentSamples,1);
           nMix = size(obj.mixtureSamples,1);
           mixtureInstanceRemaining = ones(nMix,1);
           curve = zeros(1,nMix);
           for j = 1:nMix
               c = randsample(nComp, 1);
               remainingMixtureIndices = find(mixtureInstanceRemaining);
               [dist,mixtureIndex] = obj.distanceTable.getNearestNeighbor(obj.componentSamples(c), c, obj.mixtureSamples(remainingMixtureIndices), remainingMixtureIndices);
               curve(1,j) = dist;
               mixtureInstanceRemaining(mixtureIndex) = 0;
           end
       end
       
       function [distanceCurve] = makeDistanceCurve(obj)
           curves = zeros(obj.numCurvesToAverage, size(obj.mixtureSamples,1));
           for i = 1:obj.numCurvesToAverage
              curves(i,:) = obj.makeSingleCurve(); 
           end
           averages = mean(curves,1);
           distanceCurve = prctile(averages,obj.percentiles);
       end
   end
end