addpath("/ssdata/alphamax2/distcurve/estimator");
trainData = load("/ssdata/alphamax2/data/alphamaxEstimatorTrainData.mat");
indices = randperm(size(trainData.curves,1));
xTrain = minmaxScale(trainData.curves(indices(1:800000),1:99));
xVal = minmaxScale(trainData.curves(indices(800001:end),1:99));
yTrain = trainData.alphas(indices(1:800000))';
yVal = trainData.alphas(indices(800001:end))';
layers = [featureInputLayer(99)
    fullyConnectedLayer(32)
    batchNormalizationLayer
    reluLayer
    dropoutLayer(.5)
    fullyConnectedLayer(32)
    batchNormalizationLayer
    reluLayer
    dropoutLayer(.5)
    fullyConnectedLayer(32)
    batchNormalizationLayer
    reluLayer
    dropoutLayer(.5)
    fullyConnectedLayer(1)
    reLuZeroOneLayer("reLuZeroOne")
    maeLoss("maeLoss")];
miniBatchSize=128;
validationFrequency = floor(numel(yTrain)/miniBatchSize);
options = trainingOptions('adam',...
    'MiniBatchSize',miniBatchSize,...
    'Shuffle','every-epoch',...
    'ValidationData',{xVal,yVal},...
    'ValidationFrequency',validationFrequency,...
    'Plots','training-progress',...
    'Verbose',false,...
    'ExecutionEnvironment','cpu');
net = trainNetwork(xTrain,yTrain,layers,options);

