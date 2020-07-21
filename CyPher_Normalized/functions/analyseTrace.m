function [steepest, start, stop, cutTrace] = analyseTrace(trace,gradFilt,SE,cuttingWin)
%start measurement for the average curve as a template
traceSmth = smooth(trace)';
%get points with steepest decay
filtered = imfilter(traceSmth,gradFilt); %minima represent steepest slope of one stim
filtered_uncut = -filtered; %opposite sign to detect maxima by dilatation
dil = imdilate(filtered_uncut,SE);
% cut to remove borders
cuttingWin = cuttingWin*2+1;
dil = dil(cuttingWin:end);
filtered_cut = filtered_uncut(cuttingWin:end);
locMin = dil - filtered_cut;
steepest = find(locMin == 0);

%get points with lowest slope

filteredConv_uncut = abs(filtered_uncut);
filteredConv_uncut = -filteredConv_uncut;
dil = imdilate(filteredConv_uncut,SE);
% cut to remove borders
dil = dil(cuttingWin:end);
filteredConv = filteredConv_uncut(cuttingWin:end);
locMin = dil - filteredConv;
lowest = find(locMin == 0);

start =lowest;
stop = [lowest(2:end),length(trace)];
cutTrace = traceSmth(cuttingWin:end);

end