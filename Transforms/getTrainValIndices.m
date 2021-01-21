function [trainIndices, valIndices] = getTrainValIndices(indices, val_frac)
    % Given a list of indices, that possibly contains duplicates, separate into
    % a set of training indices and validation indices of size approximately
    % equal to val_frac

    % create a map of unique index to the locations in the indices list 
    indexToCount = containers.Map('KeyType','int32','ValType','int32');
    for loc = 1:length(indices)
        idx = indices(loc);
        if isKey(indexToCount,idx)
            indexToCount(idx) = indexToCount(idx) + 1;
        else
            indexToCount(idx) = 1;
        end
    end
    uniqueIndices = cell2mat(m.keys())';
    uniqueIndices = uniqueIndices(randperm(length(uniqueIndices)));
    split = ceil(length(indices) * val_frac);
    trainUnique = uniqueIndices(1:split);
    valUnique = uniqueIndices(split+1:end);
    trainIndices = [];
    valIndices = [];
    for i = 1:length(trainUnique)
        idx = trainUnique(i);
        trainIndices = [trainIndices, ones(1,indexToCount(idx)) * idx];
    end
    for i = 1:length(valUnique)
        idx = valUnique(i);
        valIndices= [valIndices, ones(1,indexToCount(idx)) * idx];
    end
end

