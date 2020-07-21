%detectStim_forBl
%-------------------------------------------------------------------
%this function finds events in traces of on mean curve to establish
% a bleaching curve in the end
%-------------------------------------------------------------------
% Version from 11.12.2019, 
% written by Eva-Maria Weiss //mol PSY UKER
%--------------------------------------------------------------------
% Syntax
% [positions]= detectStim(M,range,cuttingWin)
%--------------------------------------------------------------------
% Description
% 
% M = vector containing the mean curve,
% range = frame range within sitmulations are given
% cutting window = cut off corrupt windows at the beginning;
% (1) Selection section containing stimulations // cut off defined number
%     of frames, cut off defined tail
% (2) define and apply edge filter to get gradient
% (3) local minima represents then steepest decays in curves; characterize
%      vesicle release
% (4) opposite sign and detection of local maxima
%-----------------------------------------------------------------------------------

function [positions,nStim] = detectStim_forBl(M, range, cuttingWin,nStim,varargin)

if nargin == 5
    firstStim = varargin{1};
end

dataCal = M(1,1:range);

%establish filters and masks
gradFilt = [-2 -1 0 1 2];
SE = ones(1,cuttingWin);

if exist('firstStim','var')
    [starts, stops, dF, cutted, nStim,win] = getEdges(dataCal,gradFilt,SE,cuttingWin,nStim,0,firstStim);
else
    [starts, stops, dF, cutted, nStim,win] = getEdges(dataCal,gradFilt,SE,cuttingWin,0,nStim);
end


positions.start = starts;
positions.stop = stops;
positions.deltaF = dF;
positions.cuttedM = cutted;
positions.cutWin = win;

end




