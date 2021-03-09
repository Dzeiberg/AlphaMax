sampler = SyntheticSampler("data/syntheticParameters.mat",'setNumberEnd',100);
curves = zeros(sampler.len,100);
alphas = zeros(sampler.len);
cc = @(comp,mix)CurveConstructor(comp,mix,'useGPU',true);
[curves] = makeCurves(sampler,'constructorHandle',cc);
