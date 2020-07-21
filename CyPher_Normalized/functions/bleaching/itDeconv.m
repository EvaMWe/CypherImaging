% Belaching Correction by ITERATIVE DECONVOLUTION
% input:
% iMeasure = not corrected, but normalized curve
% lambda = coefficient calculated from cfit object

function iCorr = itDeconv (iMeasure, lambda)

iCorr = zeros(size(iMeasure));
    for i = 1:length(iMeasure)
        iCorr(i) = iMeasure(i) - sum(lambda.*iMeasure(1:i)); 
    end
end