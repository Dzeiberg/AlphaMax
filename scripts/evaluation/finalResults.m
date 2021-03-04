datasets = struct();
resultFiles = dir("data/results/distCurveMode1/*.mat");
absErrs = struct("alphaMaxNet",[],...
    "distCurve",[],...
    "alphaMax",[]);
disp(["Dataset","AlphaMaxNet","AlphaMax","DistCurve"]);
for fileNum = 1:length(resultFiles)
    filename = replace(resultFiles(fileNum).name,".mat","");
    
    ds = load(strcat(resultFiles(fileNum).folder,"/",resultFiles(fileNum).name));
    ds = ds.ds;
    datasets.(filename) = ds;
    
    amnetAbsErrs = mean(abs(cell2mat(ds.results.alphaMaxNet.alphaHat) - cell2mat(ds.results.alpha)));
    absErrs.alphaMaxNet = [absErrs.alphaMaxNet;amnetAbsErrs];
    
    amAbsErrs = mean(abs(cell2mat(ds.results.alphaMaxInflection.alphaHat) - cell2mat(ds.results.alpha)));
    absErrs.alphaMax = [absErrs.alphaMax;amAbsErrs];
    
    dcAbsErrs = mean(abs(cell2mat(ds.results.distCurve.alphaHat) - cell2mat(ds.results.alpha)));
    absErrs.distCurve= [absErrs.distCurve;dcAbsErrs];
    
    disp({filename,mean(amnetAbsErrs,'all'),...
        mean(amAbsErrs,'all'),...
        mean(dcAbsErrs,'all')});
end
disp(["Overall",mean(absErrs.alphaMaxNet,'all'),...
    mean(absErrs.alphaMax,'all'),...
    mean(absErrs.distCurve,'all')]);