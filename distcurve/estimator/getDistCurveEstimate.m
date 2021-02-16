function [alphaHat] = getDistCurveEstimate(curve,varargin)
    args = inputParser;
    addOptional(args,'estimator',"none");
    parse(args,varargin{:});
    args = args.Results;
    if isstring(args.estimator) && strcmp(args.estimator,"none")
        estimator = load("network.mat");
        estimator = estimator.net;
    elseif isa(args.estimator, 'SeriesNetwork')
        estimator = args.estimator;
    else
        error("estimator must either be a path to a struct with a field net or a SeriesNet object");
    end
    alphaHat = predict(estimator,curve/sum(curve));
end

