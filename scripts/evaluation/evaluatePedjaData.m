files = dir("data/datasets_pedja/*.mat");
addpath("distcurve","alphamax");
for fileNum = 1:length(files)
    disp([fileNum,length(files)])
    if ~isfile(strcat("data/results/results_pedja/",files(fileNum).name))
        results = struct();
        disp(files(fileNum).name)
        ds = load(strcat(files(fileNum).folder,"/",files(fileNum).name));
        ds = ds.data;
        for instNum = 1:size(ds.xP,2)
            disp(strcat("~~~~",num2str(instNum),'/',num2str(size(ds.xP,2))))
            xP = ds.xP{instNum}';
            xU = ds.xU{instNum}';
            [results.distCurve.alphahat{instNum},results.distCurve.curves{instNum}] = runDistCurve(xU,xP,'transform','none');
            results.distCurve.absErr{instNum} = abs(results.distCurve.alphahat{instNum} - ds.alpha);
            [results.alphaMaxInflection.alphaHat{instNum},~] = runAlphaMax(xU,xP,'useEstimatorNet',false,'transform','none');
            results.alphaMaxInflection.absErrs{instNum} = abs(results.alphaMaxInflection.alphaHat{instNum} - ds.alpha);
            [results.alphaMaxNet.alphaHat{instNum},~] = runAlphaMax(xU,xP,'useEstimatorNet',true,'transform','none');
            results.alphaMaxNet.absErrs{instNum} = abs(results.alphaMaxNet.alphaHat{instNum} - ds.alpha);
        end
        save(strcat("data/results/results_pedja/",files(fileNum).name),'results');
    end
end