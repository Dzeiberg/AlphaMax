trainData = load("/ssdata/ClassPriorEstimationPrivate/data/trainData/fracLabelsNormed/train_data.mat");
indices = randperm(size(trainData.x,1));
xTrain = trainData.x(indices(1:800000),1:100);
xVal = trainData.x(indices(800001:end),1:100);
yTrain = trainData.y(indices(1:800000));
yVal = trainData.y(indices(800001:end));
layers = [featureInputLayer(100)
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
