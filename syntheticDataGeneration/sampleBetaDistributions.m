function [dist, a0, a1, b0, b1] = sampleBetaDistributions(varargin)
addpath("../distcurve/distanceMetrics/")
% sampleBetaDistributions - sample parameters for the positive and negative
% component densities and calculate the normalized distance between
% functions for these two distributions as described in Yang et al. (2019)
%
% component and mixture points are sampled from the following two
% distributions:
% ci ~ Beta(a1, b1)
% mi ~ alpha * Beta(a1, b1) + (1-alpha) Beta(a0, b0)
%
% Hyper-parameters above are sampled as follows:
% a0 ~ Uniform(c,d)
% b0 ~ a0 * Uniform(e,f)
% a1 ~ a0 * (1 + Beta(g, h))
% b1 ~ b0 * (1 + Beta(i, j))
%
% Optional Arguments - hyper-parameters used in sampling parameters to positive and negative density beta distributions:
%   c - double > 0 - default 2
%   d - double > c - default 100
%   e - double > 1 - default 1
%   f - double > e - default 10
%   g - double > 0 - default .5
%   h - double > 0 - default .5
%   i - double > 0 - default .5
%   j - double > 0 - default .5
%   numSamples = int - default 1000 - number of samples to draw from
%   positive and negative distributions used to calculate distance between
%   distributions
%
% Author: Daniel Zeiberg
% Email: zeiberg.d@northeastern.edu
% Website: dzeiberg.github.io
% Nov 2020; Last Revision: 16-Nov-2020
c_default = 2;
d_default = 100;
e_default = 1;
f_default = 10;
g_default = .5;
h_default = .5;
i_default = .5;
j_default = .5;
numSamples_default = 1000;
p= inputParser;
addOptional(p,'c',c_default);
addOptional(p,'d',d_default);
addOptional(p,'e',e_default);
addOptional(p,'f',f_default);
addOptional(p,'g',g_default);
addOptional(p,'h',h_default);
addOptional(p,'i',i_default);
addOptional(p,'j',j_default);
addOptional(p,'numSamples',numSamples_default);
parse(p,varargin{:});

% This is how sampling was described in the paper, but it doesn't seem to
% work, and isn't what I ended up using in final version of code

%a0 = random('uniform',p.Results.c, p.Results.d);
%b0 = a0 * random('uniform',p.Results.e, p.Results.f);
%a1 = a0 * (1 + random('beta',p.Results.g, p.Results.h));
%b1 = b0 * (1 + random('beta',p.Results.i, p.Results.j));

b0 = random('uniform',20,600);
b1 = random('uniform',20,600);
a0 = random('uniform',2,1000);
a1 = random('uniform',a0,1000+a0-2);

% Sample from the positive and negative distributions to calculate
% distribution distance
negSample = random('beta',a0, b0, 1, p.Results.numSamples);
posSample = random('beta',a1, b1, 1, p.Results.numSamples);
% Use samples to calculate distance between distributions
yang = Yang(1);
dist = yang.calc_distance(negSample, posSample);
end