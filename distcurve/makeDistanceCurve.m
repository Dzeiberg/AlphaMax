function [curve] = makeDistanceCurve(positiveSamples,unlabeledSamples,varargin)
% makeDistanceCurve - Given 1-dimensional samples from positive and
%                     unlabeled set, construct curve used to estimate class
%                     prior as described in
% Zeiberg et al. (2020) https://doi.org/10.1609/aaai.v34i29.6151
%
% Syntax: [curve] = makeDistanceCurve(positiveSamples, unlabeledSamples)
%
% Required Arguments:
%   positiveSamples - (1 x n_p) double - scores for each point in positive
%                                        sample
%
%   unlabeledSamples - (1 x n_p) double - scores for each point in
%                                         unlabeled sample
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
% Outputs:
%   curve - (1 x 100) double - distance values used by the estimator
%                              network
% Examples:
%   positiveSamples = randn(50);
%   unlabeledSamples = randn(2000);
%   [curve] = makeDistanceCurve(positiveSamples, unlabeledSamples);
%
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: distanceMetrics/DistanceMetric.m
%
% Author: Daniel Zeiberg
% Email: zeiberg.d@northeastern.edu
% Website: dzeiberg.github.io
% Nov 2020; Last Revision: 16-Nov-2020

% Header template taken from: 
% Denis Gilbert (2020). M-file Header Template (https://www.mathworks.com/matlabcentral/fileexchange/4908-m-file-header-template), MATLAB Central File Exchange. Retrieved November 16, 2020.
%------------- BEGIN CODE ------------------------
% ------------ Parse and Validate Parameters -----
defaultNumCurvesToAverage = 10;
defaultDistanceMetric = "manhattan";
validDistanceMetrics = {'manhattan','euclidian','cosine','yang1','yang2'};
p= inputParser;
isValidScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
isSubclass = @(x) (superclasses(x) == "DistanceMetric");
isValidDistStr = @(x) (any(validatestring(x,validDistanceMetrics)));
isValidDistanceMetric =  @(x) isSubclass(x) || isValidDistStr(x);
hasCorrectShape = @(s) size(s,1)==1 && size(s,2) >=1;
addRequired(p, "positiveSamples", @(s) hasCorrectShape(s));
addRequired(p, "unlabeledSamples", @(s) hasCorrectShape(s));
addOptional(p,'numCurvesToAverage',defaultNumCurvesToAverage,isValidScalarPosNum);
addOptional(p,'distanceMetric',defaultDistanceMetric,isValidDistanceMetric);
parse(p,positiveSamples,unlabeledSamples,varargin{:});
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
        distanceMetric = p.Results.distanceMetric;
% all arguments accessed via: p.Results.<argname>
%-------------- End Parameter Parsing------------

%------------- END OF CODE --------------
end
