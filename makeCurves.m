function [curves] = makeCurves(sampler, constructorHandle)
    % For each instance in sampler, make the distance curve
    % Required Arguments:
    %   - sampler : instance of a subclass of Sampler
    %   - constructorHandle : a handle to CurveConstructor with all
    %   optional arguments assigned: @(componentSamples,mixtureSamples)=
    %   CurveConstructor(componentSamples, mixtureSamples,
    %   'argname1',argValue1, ...)
    %
    % Return Value:
    %   curves : double (sampler.getLength() x
    %   size(constructorHandle.percentiles, 1) : distance curves for each
    %   instance in the sampler
    % Create dummy instance of constructor to determine curve length
    curveLength = size(constructorHandle(zeros(1,1),zeros(1,1)).percentiles, 2);
    curves = zeros(sampler.getLength(), curveLength);
    times = 0
    f = waitbar(0,strcat('0/',num2str(sampler.getLength()), '   ---   average time: ',num2str(times/1)));
    pause(0.00000001);
    sLength = sampler.getLength();
    for sampleNum = 1:sLength
       tic;
       [compSample,mixSample] = sampler.getSample();
       constructor = constructorHandle(compSample, mixSample);
       curves(sampleNum,:) = constructor.makeDistanceCurve();
       elapsedTime = toc;
       times = times + elapsedTime;
       waitbar(sampleNum/sLength, f, strcat(num2str(sampleNum),'/',num2str(sLength), '   ---   average time: ',num2str(times/sampleNum))); 
       pause(0.00000001);
    end
    close(f);
end