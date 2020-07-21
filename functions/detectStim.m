%detectStim
%-------------------------------------------------------------------
%this function finds events in traces of individual ROIs
%-------------------------------------------------------------------
% Version from 06.04.2020, 
% written by Eva-Maria Weiss //mol PSY UKER
%--------------------------------------------------------------------
% Syntax
% [deltaF, deltaF_pos] = detectStim(data, range, cuttingWin,starts,stops);
% [deltaF, deltaF_pos] = detectStim(data, range, cuttingWin,starts,stops,nStim);
%--------------------------------------------------------------------
% Description
% 
% (1) Selection section containing stimulations // cut off defined number
%     of frames, cut off defined tail
% (2) define and apply edge filter to get gradient
% (3) local minima represents then steepest decays in curves; characterize
%      vesicle release
% (4) opposite sign and detection of local maxima
%-----------------------------------------------------------------------------------

function [deltaF, stim_pos, stim_startstop] = detectStim_indiv(data, range, cuttingWin, starts, stops, varargin)

numbStim = 10;

if nargin == 6
    numbStim = varargin {1};
end
regNum = size(data,1);
dataCal = data(:,1:range);
%dataAverage = mean(dataCal);
%dataTemp = zeros(regNum, range - cuttingWin + 1);
gradFilt = [-2 -1 0 1 2];
SE = ones(1,cuttingWin*2 +1);

%create a cell array for data storage: nStim+1 x nRoi+1
VarNames = cell(1, regNum+1); 
for syn =2:regNum+1
    VarNames{syn} = sprintf('RoiNr.%i',syn-2);
end

RowNames = cell(numbStim+1,1);
RowNames{1,1} = 'SynapsesNb'; 
for stim = 2:numbStim+1
    RowNames{stim,1} = sprintf('Stim_.%i',stim-1);
end

deltaF = cell(numbStim+1, regNum+1);
stim_startstop = cell(numbStim+1, regNum+1);

deltaF(:,1) = RowNames;
deltaF(1,:) = VarNames;

stim_startstop(:,1) = RowNames;
stim_startstop(1,:) = VarNames;


for i = 1:regNum
    trace = dataCal(i,:);
    [steepest, startIndiv, stopIndiv, cuttedTrace] = getEdges(trace,gradFilt,SE,cuttingWin);
    % check if stimuli are in the list, due to noisy data could orrury -->
    % validity check, just stimuli in the list are stored later
    listOfStim = getIndivResponders(positionAv, steepest, startAV, stopAV);
    
    %here 
    [startStim,stopStim] = getNearestNeighbor(startIndiv,startAV,stopIndiv,stopAV);
    
    % to reduce the disturbing effect of noise the values next to the
    % detected points are taken to average them.
    startStimMat = repmat((startStim -1),3,1) + (0:2)';
    %stopStim = stopAV(listOfStim);
    stopStimMat = repmat((stopStim -1),3,1) + (0:2)';
    traceMat = repmat(cuttedTrace',1,numbStim);
    startStimMat(startStimMat == 0) = 1;
    traceMatstart = traceMat(startStimMat);
    traceMatstop = traceMat(stopStimMat);
    temp = mean(traceMatstart,1) - mean(traceMatstop,1);
    
    dF = zeros(1,numbStim); 
    if length(temp) > sum(listOfStim)
    temp = temp(listOfStim);
    end
    dF(listOfStim) = temp;
    sprintf('%i',i)
    dF(dF <= 0) = 0;
    deltaF(2:numbStim+1,i+2) = num2cell(dF');
    
    dF_pos = zeros(1,numbStim);
    steepestAdj = zeros(1,numbStim);
    steepestAdj(1:length(steepest)) = steepest;
    if length(steepestAdj) > sum(listOfStim)
    steepestAdj = steepestAdj(listOfStim);
    end
    dF_pos(listOfStim) = steepestAdj+cutWin;
    stim_pos(2:numbStim+1,i+2) = num2cell(dF_pos');
    
    startFin = zeros(numbStim,1);
    stopFin = zeros(numbStim,1);
    startStim = startStim(listOfStim);
    stopStim = stopStim(listOfStim);
    startFin(listOfStim) = startStim+cutWin;
    stopFin(listOfStim) = stopStim+cutWin;
    
    stim_startstop(2:numbStim+1,i+2) = num2cell([startFin stopFin],2);
    
end
end





