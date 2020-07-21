% This function detects the edges in curves derived from CyPher
% experiments with bafilomycin application --> the curve is stair shaped
% and decreases
%
% INPUT: trace (double 1xn array) n=number of frames
%         gradFilt (double 1xm array) indicating the gradient filter weights, e.g.
%         [-2 1 0 1 2], estimating the first derivative 
%         SE indicates the mask for dilation, 1xk ones
%         cuttinWin: determins the frame number that is cutted off trace's
%         start (cuttingWin = 2*cuttingWin + 1)
% PROCEDURE
% 1) trace is smoothed by moving average
%---GET STEEPEST POINTS 
% 2) gradient filter is applied for 1. derivative --> minima represent the
%    - steepest slope of one stim (slope is negative;
%    - reverse sign (minima get maxima --> for dilation)
% 3) dilation, in a sliding window all values are set to the local maximum
% within that window
% 4) get real maxima by subtracting dilated trace and inverted 1°grad trace
% 5) maxima and therefore steepest points in the curve are the zeros
%---GET PLATEAU THAT ARE POINTS WITH APPROXIMATLY 0 SLOPE
% 6) These are the values next to zero: convert all values within the 1°grad trace to their absolute
% values
% 7)invert the sign --> now nearest zeros are maxima
% 8) again: dilation, subtraction, search for zeros

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