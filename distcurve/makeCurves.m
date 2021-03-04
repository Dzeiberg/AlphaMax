function [curves] = makeCurves(sampler, varargin)
    %% For each instance in sampler, make the distance curve
    % Required Arguments:
    %   - sampler : either:
    %                   - struct with fields xPos, xUnlabeled
    %                        (see ../StructSampler)
    %                   - instance of a subclass of Sampler
    %
    % Optional Arguments
    %   - constructorHandle : a handle to CurveConstructor constructor
    %                       function with all optional arguments assigned:
    %
    % default:
    % @(componentSamples,mixtureSamples)=CurveConstructor(componentSamples,
    %                                                     mixtureSamples)
    %
    %   - quiet     - bool - whether to turn off the progress bar
    %
    %   - savePath - None - if specified, save the curves to the specified
    %                       file
    % Return Value:
    %   curves : double (sampler.getLength() x
    %   size(constructorHandle.percentiles, 1) : distance curves for each
    %   instance in the sampler
    %% Process Arguments and Initialize
    addpath(fullfile(fileparts(mfilename('fullpath')),"../"));
    addpath(fullfile(fileparts(mfilename('fullpath')),"../syntheticDataGeneration"));
    if ~ismember('Sampler',superclasses(sampler))
        if isstring(sampler) && isfile(sampler)
            sampler = SyntheticSampler(sampler);
        elseif isstruct(sampler) && isfield(sampler,'xPos') && isfield(sampler,'xUnlabeled')
            sampler = StructSampler(sampler);
        else
            error('sampler must either be an instance of a subclass of Sampler or a path to a .mat file containing parameters for SyntheticSampler');
        end
    end
    p= inputParser;
    defaultConstructor= @(componentSamples,mixtureSamples) ...
        CurveConstructor(componentSamples,mixtureSamples);
    % Optional Arguments
    addOptional(p,'constructorHandle',defaultConstructor);
    addOptional(p,'quiet', true);
    addOptional(p,'savePath','')
    parse(p,varargin{:});
    if ~strcmp(p.Results.savePath,'')
        disp(strcat('saving to ',p.Results.savePath));
    end
    len = sampler.getLength();
    % Create dummy instance of constructor to determine curve length
    constructorHandle = p.Results.constructorHandle;
    curveLength = size(constructorHandle(zeros(1,1),zeros(1,1)).percentiles, 2);
    curves = zeros(len, curveLength);
    %% Make Curves
    times = 0;
    if ~ p.Results.quiet
       f = waitbar(0,strcat('making distance curves: ','0/',num2str(len), '   ---   average time: ',num2str(times/1)));
       pause(0.00000001);
    end
    for sampleNum = 1:len
       tic;
       [compSample,mixSample,~] = sampler.getSample();
       constructor = constructorHandle(compSample, mixSample);
       curves(sampleNum,:) = constructor.makeDistanceCurve();
       elapsedTime = toc;
       times = times + elapsedTime;
       if ~ p.Results.quiet
           waitbar(sampleNum/len, f, strcat('making distance curves: ',num2str(sampleNum),'/',num2str(len), '   ---   average time: ',num2str(times/sampleNum))); 
           pause(0.00000001);
       else
           warning(strcat('making distance curves: ',num2str(sampleNum),'/',num2str(len), '   ---   average time: ',num2str(times/sampleNum)));
       end
    end
    if ~ p.Results.quiet
        close(f);
    end
    if p.Results.savePath
       save(p.Results.savePath,'curves','-mat'); 
    end
end