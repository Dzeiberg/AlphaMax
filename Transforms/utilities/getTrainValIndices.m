function [trainIndices, valIndices] = getTrainValIndices(indices, val_frac)
    % Given a list of indices, that possibly contains duplicates, separate into
    % a set of training indices and validation indices of size approximately
    % equal to val_frac

    % create a map of unique index to the locations in the indices list 
    indexToCount = containers.Map('KeyType','int32','ValueType','int32');
    for loc = 1:length(indices)
        idx = indices(loc);
        if isKey(indexToCount,idx)
            indexToCount(idx) = indexToCount(idx) + 1;
        else
            indexToCount(idx) = 1;
        end
    end
    uniqueIndices = cell2mat(indexToCount.keys())';
    uniqueIndices = uniqueIndices(randperm(length(uniqueIndices)));
    split = ceil(length(uniqueIndices) * (1 - val_frac));
    trainUnique = uniqueIndices(1:split);
    valUnique = uniqueIndices(split+1:end);
    trainIndices = [];
    valIndices = [];
    for i = 1:length(trainUnique)
        idx = trainUnique(i);
        itoc = indexToCount(idx);
        assert(isa(idx,'int32'));
        idxs = ones(1,itoc,'int32') * idx;
        trainIndices = [trainIndices, idxs];
    end
    for i = 1:length(valUnique)
        idx = valUnique(i);
        valIndices= [valIndices, ones(1,indexToCount(idx),'int32') * idx];
    end
end

