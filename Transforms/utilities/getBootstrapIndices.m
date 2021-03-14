function [inBagIndices,outOfBagIndices] = getBootstrapIndices(nPoints)
    %GETBOOTSTRAPINDICES Sample with replacement from the set of indices to use
    %as in bag samples and use the remainders as out-of-bag samples; model will
    %be trained on the in-bag and contribute to the final predictions of the
    %out-of-bag samples
    %
    % get in bag indices
    inBagIndices = datasample(1:nPoints,nPoints);
    % use the rest as outof bag
    outOfBagIndices = setdiff(1:nPoints,inBagIndices);
end

