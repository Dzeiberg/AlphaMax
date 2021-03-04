classdef CurveConstructor
   properties
       componentSamples
       mixtureSamples
       numCurvesToAverage
       distanceTable
       percentiles
       useGPU
   end
   
   methods
       function obj = CurveConstructor(componentSamples,mixtureSamples,varargin)
           % CurveConstructor - Given 1-dimensional samples from positive and
           %                     unlabeled set, construct curve used to estimate class
           %                     prior as described in
           % Zeiberg et al. (2020) https://doi.org/10.1609/aaai.v34i29.6151
           %
           %
           % Required Arguments:
           %   componentSamples - (nP x dim) double - component samples
           %
           %   mixtureSamples - (nU x dim) double - mixture samples
           %
           % Optional Arguments:
           %   numCurvesToAverage - int - default: 10 - number of times to repeat 
           %                                            curve construction after which
           %                                            all curves will be averaged
           %
           %   distanceMetric - {'euclidean'; 'seuclidean'; 'cityblock'; 'chebychev';
           %                     'mahalanobis'; 'minkowski'; 'cosine'; 'correlation'; ...
           %                     'hamming'; 'jaccard'; 'squaredeuclidean'} or 
           %                     instance of subclass of distanceMetrics/DistanceMetric;...
           %                    - default:manhattan - distance metric to
           %                    use when calculatingthe nearest neighbor
           %                     NOTE: for best performance, use one of the
           %                     strings in the list, as these are
           %                     compatible with the pdist2 gpuArray
           %                     function, otherwise computation will not
           %                     be done on the gpu
           %
           %   percentiles - vector[int] in range [0,100] - default 0:99 -
           %                       after averaging across all curves, final
           %                       distance curve will be these percentiles
           %                       values of the averages
           %                 Warning : modifying this argument will result
           %                 in a distance curve that is likely
           %                 incompatible with the pre-trained class prior
           %                 estimator used in estimator/getEstimate.m 
           %
           %   useGPU - bool - default false - whether do do computation on
           %   GPU; requires cuda compatible gpu and the matlab cuda
           %   toolkit; see note on distanceMetric regarding CUDA
           %   compatible distance metrics
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
           defaultNumCurvesToAverage = 25;
           defaultDistanceMetric = 'cityblock';
           defaultPercentiles= 0:99;
           p= inputParser;
           isValidScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
           isSubclass = @(x) strcmp(superclasses(x),"DistanceMetric");
           hasCorrectShape = @(s) size(s,1) >= 1 && size(s,2) >=1;
           areValidPercentiles = @(l) all(l >= 0) && all(l <= 100);
           addRequired(p, "componentSamples", @(s) hasCorrectShape(s));
           addRequired(p, "mixtureSamples", @(s) hasCorrectShape(s));
           addOptional(p,'numCurvesToAverage',defaultNumCurvesToAverage,isValidScalarPosNum);
           addOptional(p,'distanceMetric', defaultDistanceMetric);
           addOptional(p, 'percentiles',defaultPercentiles,areValidPercentiles);
           addOptional(p, 'useGPU', true);
           parse(p,componentSamples,mixtureSamples,varargin{:});
           obj.componentSamples = p.Results.componentSamples;
           obj.mixtureSamples = p.Results.mixtureSamples;
           obj.numCurvesToAverage = p.Results.numCurvesToAverage;
           obj.percentiles = p.Results.percentiles;
           assert(size(p.Results.componentSamples,2) == size(p.Results.mixtureSamples,2), "component and mixture samples must have the same dimension at index 2")
           pdistCompatible = {'euclidean'; 'seuclidean'; 'cityblock'; 'chebychev'; ...
            'mahalanobis'; 'minkowski'; 'cosine'; 'correlation'; ...
            'hamming'; 'jaccard'; 'squaredeuclidean'};
           warn = @()warning(strcat('for best performance distanceMetric should be one of {',strjoin(pdistCompatible,','),'}'));
           badDist = @()error(strcat("distanceMetric must be a subclass of DistanceMetric or one of: ",strjoin(pdistCompatible,', '), ', yang1, yang2'));
           obj.useGPU = p.Results.useGPU;
           if isSubclass(p.Results.distanceMetric)
               distanceMetric = p.Results.distanceMetric;
               warn();
           elseif ischar(p.Results.distanceMetric)
               if ismember(p.Results.distanceMetric, pdistCompatible)
                   distanceMetric = p.Results.distanceMetric;
               elseif strcmp(extractBefore(p.Results.distanceMetric, length(p.Results.distanceMetric)), "yang")
                   warn();
                   obj.useGPU = false;
                   p = str2double(extractAfter(p.Results.distanceMetric, length(p.Results.distanceMetric) - 1));
                   distanceMetric = Yang(p);
                   distanceMetric = @(x,y) distanceMetric.calc_distance(x,y);
               else
                   badDist();
               end
           else
               badDist();
           end
           obj.distanceTable = DistanceTable(obj.componentSamples, obj.mixtureSamples,distanceMetric);
           if obj.useGPU
               obj.componentSamples = gpuArray(obj.componentSamples);
               obj.mixtureSamples = gpuArray(obj.mixtureSamples); 
           end
       end
       
       function [curve] = makeSingleCurve(obj)
           nComp = size(obj.componentSamples,1);
           nMix = size(obj.mixtureSamples,1);
           mixtureInstanceRemaining = true(nMix,1);
           curve = zeros(1,nMix);
           if obj.useGPU
            curve = gpuArray(curve);
           end
           f = waitbar(0, 'calculating distances');
           pause(0.0000001);
           for j = 1:nMix
               waitbar(j/nMix,f,strcat('calculating distances ',num2str(j), '/',num2str(nMix)));
               pause(0.000001);
               c = randsample(nComp, 1);
               [dist,mixtureIndex] = obj.distanceTable.getNearestNeighbor(c,mixtureInstanceRemaining);
               curve(1,j) = dist;
               mixtureInstanceRemaining(mixtureIndex) = false;
           end
           close(f);
       end
       
       function [distanceCurve] = makeDistanceCurve(obj)
           curves = zeros(obj.numCurvesToAverage, size(obj.mixtureSamples,1));
           if obj.useGPU
            curves = gpuArray(curves);
           end
           parfor i = 1:obj.numCurvesToAverage
              curves(i,:) = obj.makeSingleCurve(); 
           end
           distanceCurve = prctile(mean(curves,1),obj.percentiles,2);
           %distanceCurve = mean(prctile(curves,obj.percentiles,2),1);
           if obj.useGPU
              distanceCurve = gather(distanceCurve); 
           end
       end
   end
end