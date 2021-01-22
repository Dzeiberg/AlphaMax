function [alphaHat] = getEstimate(curve,varargin)
    args = inputParser;
    addOptional(args,'estimator',"none");
    parse(args,varargin{:});
    args = args.Results;
    if isstring(args.estimator) && strcmp(args.estimator,"none")
        estimator = load("network.mat");
        estimator = estimator.net;
    else
        estimator = args.estimator;
    end
    alphaHat = predict(estimator,curve/sum(curve));
end

