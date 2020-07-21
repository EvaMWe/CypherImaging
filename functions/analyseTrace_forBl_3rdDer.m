%this is a function detecting the edges in a trace by the third derivative

function [starts, stops, dF,trace,nStim] = analyseTrace_forBl_3rdDer(trace,gradFilt,SE,cuttingWin,nStim)
%start measurement for the average curve as a template
traceSmth = smooth(trace)';
%first derivative
filtered = imfilter(traceSmth,gradFilt); %minima represent steepest slope of one stim
%second derivative
filtered_2 = imfilter(filtered, gradFilt); %
%third derivative
filtered_3 = imfilter(filtered_2, gradFilt); %bend
filtered_3_invert = abs(filtered_3);

%% get maxima in third derivative
dil = imdilate(filtered_3_invert,SE);
dil = dil(cuttingWin:end);
filtered_cut3 = filtered_3_invert(cuttingWin:end);

locMin = dil - filtered_cut3;
edge = find(locMin == 0);

% maxima = left bended --> stimulation start
%minima = right bended --> release stop
values = filtered_2_original(cuttingWin:end);
trace = traceSmth(1,cuttingWin:end);

starts = sharpest(values(sharpest) > 0);
values_start = trace(starts);

stops = sharpest(values(sharpest) < 0);
if stops(1) < starts(1)
    stops(1) = [];   
end

if length(stops) < nStim
    nStim = length(stops);
end

if length(stops) < length(starts)
    starts = starts(1:length(stops));
    values_start = values_start(1:length(stops));
end

values_stop = trace(stops);

dF = values_start(1,1:nStim) -values_stop(1,1:nStim);

end





