function [curves] = makeCurves(sampler, constructorHandle, varargin)
    % For each instance in sampler, make the distance curve
    % Required Arguments:
    %   - sampler : instance of a subclass of Sampler
    %   - constructorHandle : a handle to CurveConstructor with all
    %   optional arguments assigned: @(componentSamples,mixtureSamples)=
    %   CurveConstructor(componentSamples, mixtureSamples,
    %   'argname1',argValue1, ...)
    %
    % Optional Arguments
    %   - setNumber - int - focus on just one parameter set (10 instances) rather than all
    %                       1M instances; if not set, process all 1M
    %                       instances
    %   - quiet     - bool - whether to turn off the progress bar
    %
    %   - savePath - None - if specified, save the curves to the specified
    %                       file
    % Return Value:
    %   curves : double (sampler.getLength() x
    %   size(constructorHandle.percentiles, 1) : distance curves for each
    %   instance in the sampler
    addpath('syntheticDataGeneration');
    addpath('distcurve');
    if ~ismember('Sampler',superclasses(sampler))
        if ischar(sampler) && isfile(sampler)
            sampler = SyntheticSampler(sampler);
        else
            error('sampler must either be an instance of a subclass of Sampler or a path to a .mat file containing parameters for SyntheticSampler');
        end
    end
    p= inputParser;
    addOptional(p,'setNumber', 0);
    addOptional(p,'quiet', false);
    addOptional(p,'savePath','')
    parse(p,varargin{:});
    setNum = p.Results.setNumber;
    if setNum == 0
       len = sampler.getLength();
    else
       len = sampler.instancesPerSet;
       sampler.assignSetValue(setNum);
    end
    % Create dummy instance of constructor to determine curve length
    curveLength = size(constructorHandle(zeros(1,1),zeros(1,1)).percentiles, 2);
    curves = zeros(len, curveLength);
    times = 0;
    if ~ p.Results.quiet
       f = waitbar(0,strcat('0/',num2str(len), '   ---   average time: ',num2str(times/1)));
       pause(0.00000001);
    end
    for sampleNum = 1:len
       tic;
       [compSample,mixSample] = sampler.getSample();
       constructor = constructorHandle(compSample, mixSample);
       curves(sampleNum,:) = constructor.makeDistanceCurve();
       elapsedTime = toc;
       times = times + elapsedTime;
       if ~ p.Results.quiet
           waitbar(sampleNum/len, f, strcat(num2str(sampleNum),'/',num2str(len), '   ---   average time: ',num2str(times/sampleNum))); 
           pause(0.00000001);
       else
           warning(strcat(num2str(sampleNum),'/',num2str(len), '   ---   average time: ',num2str(times/sampleNum)));
       end
    end
    if ~ p.Results.quiet
        close(f);
    end
    if p.Results.savePath
       save(p.Results.savePath,'curves','-mat'); 
    end
end