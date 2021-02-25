files = dir("/ssdata/ClassPriorEstimationPrivate/data/rawDatasets/*.mat");

absErrs = struct('distCurve',[],'alphaMaxInflection',[],'alphaMaxNet',[]);
for fileNum = 1:length(files)
    disp([fileNum,length(files)])
    mat = load(strcat(files(fileNum).folder,"/",files(fileNum).name));
    ds = Dataset(mat);
    ds.addTransforms('debug',true);
    ds.runAlgorithms('numReps',1);
    % DistCurve
    distCurveAlphaHats = cell2mat(ds.results.optimal.distCurve.alphaHat);
    distCurveAbsErrs = abs(distCurveAlphaHats - cell2mat(ds.results.optimal.alpha));
    absErrs.distCurve = [absErrs.distCurve;distCurveAbsErrs];
    % AlphaMax Inflection
    alphaMaxInflectionAlphaHats = cell2mat(ds.results.optimal.alphaMaxInflection.alphaHat);
    alphaMaxInflectionAbsErrs = abs(alphaMaxInflectionAlphaHats - cell2mat(ds.results.optimal.alpha));
    absErrs.alphaMaxInflection = [absErrs.alphaMaxInflection; alphaMaxInflectionAbsErrs];
    % AlphaMax Net
    alphaMaxNetAlphaHats = cell2mat(ds.results.optimal.alphaMaxNet.alphaHat);
    alphaMaxNetAbsErrs = abs(alphaMaxNetAlphaHats - cell2mat(ds.results.optimal.alpha));
    absErrs.alphaMaxNet = [absErrs.alphaMaxNet; alphaMaxNetAbsErrs];
end