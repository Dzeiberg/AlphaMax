function [c] = minmaxScale(m)
    minmat = min(m,[],2);
    maxmat = max(m,[],2);
    c = (m - minmat) ./ (maxmat - minmat);
end
