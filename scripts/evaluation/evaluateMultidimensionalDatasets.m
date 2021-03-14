% Run the 3 models on the data transformed using the new transnform
% implementation
files = dir("data/datasets/*.mat");
absErrs = struct('distCurve',[],'alphaMaxInflection',[],'alphaMaxNet',[]);
for fileNum = length(files):-1:1
    if ~isfile(strcat("data/results/newTransforms/",files(fileNum).name))
        disp(files(fileNum).name)
        ds = load(strcat("data/datasets/",files(fileNum).name),'ds');
        ds = ds.ds;
        %% Run Algorithms
        ds.runAlgorithms('numReps',10);
        % DistCurve
        distCurveAlphaHats = cell2mat(ds.results.distCurve.alphaHat);
        distCurveAbsErrs = abs(distCurveAlphaHats - cell2mat(ds.results.alpha));
        absErrs.distCurve = [absErrs.distCurve;distCurveAbsErrs];
        % AlphaMax Inflection
        alphaMaxInflectionAlphaHats = cell2mat(ds.results.alphaMaxInflection.alphaHat);
        alphaMaxInflectionAbsErrs = abs(alphaMaxInflectionAlphaHats - cell2mat(ds.results.alpha));
        absErrs.alphaMaxInflection = [absErrs.alphaMaxInflection; alphaMaxInflectionAbsErrs];
        % AlphaMax Net
        alphaMaxNetAlphaHats = cell2mat(ds.results.alphaMaxNet.alphaHat);
        alphaMaxNetAbsErrs = abs(alphaMaxNetAlphaHats - cell2mat(ds.results.alpha));
        absErrs.alphaMaxNet = [absErrs.alphaMaxNet; alphaMaxNetAbsErrs];
        save(strcat("data/results/newTransforms/",files(fileNum).name),'ds');
    end
end