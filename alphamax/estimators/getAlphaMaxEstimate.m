function [alphaHat] = getAlphaMaxEstimate(ll_curve,varargin)
    % Pass the given log-likelihood curve through the class prior estimator
    %
    % Optional Arguments:
    %   - estimator : SeriesNet object or a path to a mat file containing a
    %   struct with a field "net" pointing to such an object : default
    %   alphamaxEstimator.mat
    args = inputParser;
    addOptional(args,'estimator',"alphamaxEstimator.mat");
    parse(args,varargin{:});
    args = args.Results;
    if isstring(args.estimator) && isfile(args.estimator)
        addpath(fullfile(fileparts(mfilename('fullpath')),"../../distcurve/estimator/"));
        estimator = load(args.estimator);
        estimator = estimator.net;
    elseif isa(args.estimator, 'SeriesNetwork')
        estimator = args.estimator;
    else
        error("estimator must either be a path to a struct with a field net or a SeriesNet object");
    end
    alphaHat = predict(estimator,minmaxScale(ll_curve));
end

