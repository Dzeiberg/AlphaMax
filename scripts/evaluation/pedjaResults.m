resultFiles = dir("data/results/results_pedja/*.mat");
absErrs = struct("alphaMaxNet",[],...
    "distCurve",[],...
    "alphaMaxInf",[]);
disp(["Dataset","AlphaMaxNet","AlphaMaxInf","DistCurve"]);
for fileNum = 1:length(resultFiles)
    filename = replace(resultFiles(fileNum).name,".mat","");
    
    ds = load(strcat(resultFiles(fileNum).folder,"/",resultFiles(fileNum).name));
    if isfield(ds,'results')
        ds = ds.results;
    end
    distCurveAbsErrs = cell2mat(ds.distCurve.absErr);
    alphaMaxInfAbsErrs = cell2mat(ds.alphaMaxInflection.absErrs);
    alphaMaxNetAbsErrs = cell2mat(ds.alphaMaxNet.absErrs);
    disp({filename,mean(alphaMaxNetAbsErrs),...
         mean(alphaMaxInfAbsErrs),...
         mean(distCurveAbsErrs)})
     
     absErrs.distCurve = [absErrs.distCurve,distCurveAbsErrs];
     absErrs.alphaMaxNet = [absErrs.alphaMaxNet,alphaMaxNetAbsErrs];
     absErrs.alphaMaxInf = [absErrs.alphaMaxInf,alphaMaxInfAbsErrs];
end
disp(["Overall",mean(absErrs.alphaMaxNet,'all'),...
     mean(absErrs.alphaMaxInf,'all'),...
     mean(absErrs.distCurve,'all')]);