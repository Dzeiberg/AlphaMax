function [params] = sampleDistributionParameters(sampler, varargin)
%SAMPLEDISTRIBUTIONPARAMETERS Sample parameters to the distributions from
%which the synthetic data are sampled
%   To generate a rich set of positive-unlabeled datasets, used to train
%   the class prior estimator network, data are drawn from many pairs of
%   beta distributions with varying degrees of overlap. This function
%   samples parameters to the positive and negative distributions ensuring
%   the final set distributions have a uniform degree of overlap.
%
%   Total number of parameter sets: sum(pairsPerBin)* alphasPerParameterSet
%
%   Required Arguments
%       - sampler - handle to sampleBetaDistributions with
%       hyperparameters set
%
%
%   Optional Arguments:
%       - binEdges - list[double] in [0,1) - default 0:.01:0.99 - lower bounds of the bins that determine
%       how to segment the range of normalized distance between distributions 
%       - pairsPerBin - list[int] - default repelem(1000, 100) - number of
%       positive/negative distribution pairs to generate in each bin; must
%       have same length as binEdges
%       - sampelsPerParameterSet - int - default 10 - for each pair of positive and negative
%       distributions, how many parameter sets to sample (alpha, |M|, |C| )
%       - alphaSampler - function handle - default @(numAlphas) random('uniform',0,1,1,numAlphas) - 
%         function handle that takes the sample size as anargument and returns a vector of alpha values
%       - mixtureSizeSampler - function handle - default @(mixSize) random('uniform',1000,10000, 1, mixSize) - 
%         function handle that takes the sample size as anargument and returns a vector of mixture sizes
%       - componentSizeSampler - function handle - default @(compSize) random('uniform', 100,5000, 1, compSize) - 
%         function handle that takes the sample size as anargument and returns a vector of component sizes
p= inputParser;
addOptional(p,'binEdges',0:.01:.99);
addOptional(p,'pairsPerBin',repelem(1000,100));
addOptional(p,'samplesPerParameterSet',10);
addOptional(p,'alphaSampler',@(numAlphas) random('uniform',0,1,1,numAlphas));
addOptional(p,'mixtureSizeSampler', @(mixSize) random('uniform',1000,10000, 1, mixSize));
addOptional(p,'componentSizeSampler', @(compSize) random('uniform', 100,5000, 1, compSize));
parse(p,varargin{:});
parametersAdded = 0;
n = sum(p.Results.pairsPerBin);
params = struct('a0',zeros(n,1),'a1',zeros(n,1),'b0',zeros(n,1),...
                'b1',zeros(n,1),...
                'alphas',zeros(n,p.Results.samplesPerParameterSet),...
                'mixtureSizes', zeros(n, p.Results.samplesPerParameterSet),...
                'componentSizes', zeros(n, p.Results.samplesPerParameterSet),...
                'bin', zeros(n,1));
remainingPairs = p.Results.pairsPerBin;
mybar = waitbar(0,'starting');
pause(0.00001)
while any(remainingPairs > 0)
   [distance, a0, a1, b0, b1] = sampler();
   binIndex = find(p.Results.binEdges < distance, 1, 'last');
   if remainingPairs(binIndex) > 0
       remainingPairs(binIndex) = remainingPairs(binIndex) - 1;
       frac= sum((p.Results.pairsPerBin - remainingPairs) / p.Results.pairsPerBin);
       waitbar(frac, mybar,num2str(remainingPairs))
       pause(.0000001)
       parametersAdded = parametersAdded + 1;
       params.a0(parametersAdded,:) = a0;
       params.a1(parametersAdded,:) = a1;
       params.b0(parametersAdded,:) = b0;
       params.b1(parametersAdded,:) = b1;
       params.alphas(parametersAdded,:) = ...
           p.Results.alphaSampler(p.Results.samplesPerParameterSet);
       params.mixtureSizes(parametersAdded,:) = ...
           p.Results.mixtureSizeSampler(p.Results.samplesPerParameterSet);
       params.componentSizes(parametersAdded,:) = ...
           p.Results.componentSizeSampler(p.Results.samplesPerParameterSet);
       params.bin(parametersAdded) = binIndex;
   end
end
close(mybar)
end

