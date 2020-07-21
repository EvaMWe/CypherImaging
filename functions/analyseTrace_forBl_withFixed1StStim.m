function [starts, stops, dF,trace_cut,nStim,cuttingWin] = analyseTrace_forBl_withFixed1StStim(trace,gradFilt,SE,cuttingWin,nStim,firstStim)

%start measurement for the average curve as a template
traceSmth = smooth(trace)';
%get points with steepest decay
%first deviation
filtered = imfilter(traceSmth,gradFilt); %minima represent steepest slope of one stim
%second deviation
filtered_2 = imfilter(filtered, gradFilt); %bend

%% get points with the highest bend (these are the edges)
% --> get extrema in filtered_2
%prepare curve for dilatation:take absolut values
%filtered_2_original = filtered_2;
filtered_2_inv = abs(filtered_2);
dil = imdilate(filtered_2_inv,SE);

%% cut to remove borders
cuttingWin = cuttingWin*2+1;
dil = dil(cuttingWin:end-cuttingWin);
filtered_cut2 = filtered_2_inv(cuttingWin:end-cuttingWin);
trace_cut = trace(cuttingWin:end-cuttingWin);

%% get maxima
locMin = dil - filtered_cut2;
%posMax = find(locMax == 0);

%% select according to stimulation number:
number = nStim * 2 + 4; %edges for start and stop;
val = filtered_cut2(locMin==0);
val_pos = find(locMin == 0);
if length(val) <= number
    number = length(val);
end

[~,maxs] = Maximum_median(val,number,'Dimension',2,'Type','number');
  
thresh = min(maxs);
%%

sharpest = val_pos(val >= thresh);

% maxima = right bended --> stimulation start %% accounts for CYPHER,
% f''(x) < 0
% because stimulation initiate a diminishing of fluorescence, curve decay
%minima = left bended --> release stop
% f''(x) > 0
values = filtered_2(cuttingWin:end-cuttingWin);
%trace = traceSmth(1,cuttingWin:end);

starts = sharpest(values(sharpest) < 0);
starts = [firstStim starts];
values_start = trace_cut(starts);

stops = sharpest(values(sharpest) > 0);

%% check for validity
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


if length(stops) > length(starts)
    nStim = length(starts);    
    [starts,stops]  = checkForValidity_2vec(starts,stops, nStim);    
end

if nStim > length(starts)
    nStim = length(starts);
end

values_stop = trace_cut(stops);
dF = values_start(1,1:nStim) -values_stop(1,1:nStim);

end





