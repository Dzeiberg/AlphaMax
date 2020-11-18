addpath("../syntheticDataGeneration/")
n = 10000;
params = struct('a0',zeros(n,1),'a1',zeros(n,1),'b0',zeros(n,1),...
                'b1',zeros(n,1),...
                'distance',zeros(n,1),...
                'bin', zeros(n,1));
            
for i = 1:n
    [distance, a0, a1, b0, b1] = sampleBetaDistributions('c',2,'d',1000,'e',20,'f',600);
    params.a0(i) = a0;
    params.a1(i) = a1;
    params.b0(i) = b0;
    params.b1(i) = b1;
    params.distance(i) = distance;
end
histogram(params.distance)