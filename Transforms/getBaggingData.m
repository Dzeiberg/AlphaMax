function [inBagData, inBagLabels, finalTrainIndices, finalValIndices, outOfBagData, outOfBagIndices] = getBaggingData(X, S, val_frac)
    %GETBAGGINGDATA Prep the data for training, validation, and out-of-bag
    %prediction
    % Get in-bag and out-of-bag indices
    [inBagIndices,outOfBagIndices] = getBootstrapIndices(size(X,1));
    % shuffle inBagIndices to get train and val indices
    inBagIndices = inBagIndices(randperm(length(inBagIndices)));
    [trainIndices,valIndices] = getTrainValIndices(inBagIndices, val_frac);
    inBagLabels = S([trainIndices,valIndices]);
    % normalize training data and apply normalization to validation and outOfBag
    [trainMean, trainStd, trainData] = normalize(X(trainIndices,:),[],[]);
    [~, ~, valData] = normalize(X(valIndices,:),trainMean, trainStd);
    [~,~,outOfBagData] = normalize(X(outOfBagIndices,:),trainMean,trainStd);
    % Merge train and val data and recalculate train/val indices
    inBagData = [trainData;valData];
    finalTrainIndices = 1:length(trainData);
    finalValIndices = size(trainData, 1) + 1 : size(inBagData,1));
end