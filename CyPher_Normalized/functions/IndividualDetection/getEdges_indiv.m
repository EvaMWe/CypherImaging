% Here the candidats for start and stop points in the fluorescence curve of
% individual ROI are detected.
%This function is similar to the more general function getEdges, but more
%basic. Here no validation check is performed, also no check accoding to
%number of stimulations nor first stiumlation is applied. 
% The aim is to receive all possible points. The selection occurs according
% to the start and stop points derived fom the average curve in the
% function getNearestNeighbor
function [starts, stops, cutTrace] = getEdges_indiv(trace,gradFilt,SE,cuttingWin,smth)

if smth == 1
    traceSmth = smooth(trace)';
else
    traceSmth = trace;
end

cutTrace = traceSmth(cuttingWin:end-cuttingWin);
%get points with steepest decay
%first derivative
filtered = imfilter(traceSmth,gradFilt); %minima represent steepest slope of one stim
%second derivative
filtered_2 = imfilter(filtered, gradFilt); %bend

%% get points with the highest bend (these are the edges)
% --> get extrema in filtered_2
%prepare curve for dilatation:take absolut values
%filtered_2_original = filtered_2;
filtered_2_inv = abs(filtered_2);
dil = imdilate(filtered_2_inv,SE);

dil = dil(cuttingWin:end-cuttingWin);
filtered_cut2 = filtered_2_inv(cuttingWin:end-cuttingWin);


%% get maxima
locMax = dil - filtered_cut2;


%% select real maxima
val_pos = find(locMax == 0);
sharpest = val_pos;
 

%% define start and stop
% maxima = right bended --> stimulation start %% accounts for CYPHER,
% f''(x) < 0
% because stimulation initiate a diminishing of fluorescence, curve decay
%minima = left bended --> release stop
% f''(x) > 0
values = filtered_2(cuttingWin:end-cuttingWin);

starts = sharpest(values(sharpest) < 0);

stops = sharpest(values(sharpest) > 0);

end





