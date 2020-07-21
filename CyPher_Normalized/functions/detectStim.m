%detectStim
%-------------------------------------------------------------------
%this function finds events in traces of individual ROIs
%-------------------------------------------------------------------
% Version from 27.11.2019, 
% written by Eva-Maria Weiss //mol PSY UKER
%--------------------------------------------------------------------
% Syntax
% [result]= detectStim(data,range,cuttingWin)
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

function [deltaF, deltaF_pos] = detectStim(data, range, cuttingWin)
numbStim = 2;
regNum = size(data,1);
dataCal = data(:,1:range);
dataAverage = mean(dataCal);
%dataTemp = zeros(regNum, range - cuttingWin + 1);
gradFilt = [-2 -1 0 1 2];
SE = ones(1,cuttingWin*2 +1);

[steepest, start, stop, cuttedAV] = analyseTrace(dataAverage,gradFilt,SE,cuttingWin);

[positionAv,stopAV,startAV] =checkForValidity(steepest,start,stop,numbStim);


VarNames = cell(1, regNum+2);
VarNames{2} = 'AverageCurve'; 
for syn = 3:regNum+1
    VarNames{syn} = sprintf('RoiNr.%i',syn-2);
end


RowNames = cell(numbStim+1,1);
RowNames{1,1} = 'SynapsisNb'; 
for stim = 2:numbStim+1
    RowNames{stim,1} = sprintf('Stim_.%i',stim-1);
end

%create cell arrays for data storage
% stim_pos = cell(numbStim+1, regNum+2);
% stim_pos(:,1) = RowNames;
% stim_pos(1,:) = VarNames;

deltaF = cell(numbStim+1, regNum+2);
deltaF_pos = cell(numbStim+1, regNum+2);

deltaF(:,1) = RowNames;
deltaF(1,:) = VarNames;

deltaF_pos(:,1) = RowNames;
deltaF_pos(1,:) = VarNames;

%stim_pos(2:end,2) = num2cell(positionAv);
dF = dataAverage(startAV) - dataAverage(stopAV);
deltaF(2:end,2) = num2cell(dF);
deltaF_pos(2:end,2) = num2cell(dF);

for i = 1:regNum
    trace = dataCal(i,:);
    [~, startIndiv, stopIndiv,cuttedIndiv] = analyseTrace(trace,gradFilt,SE,cuttingWin);
    % check if stimuli are in the list
    listOfStim = getIndivResponders(positionAv, steepest, startAV, stopAV);
    [startStim,stopStim] = getNearestNeighbor(startIndiv,startAV,stopIndiv,stopAV);
    
    startStimMat = repmat((startStim -1),3,1) + (0:2)';
    %stopStim = stopAV(listOfStim);
    stopStimMat = repmat((stopStim -1),3,1) + (0:2)';
    traceMat = repmat(trace',1,numbStim);
    startStimMat(startStimMat == 0) = 1;
    traceMatstart = traceMat(startStimMat);
    traceMatstop = traceMat(stopStimMat);
    temp = mean(traceMatstart,1) - mean(traceMatstop,1);
    dF = zeros(1,numbStim);
    dF(listOfStim) = temp;
    dF_pos = dF;
    dF_pos(dF_pos <= 0) = 0;
    deltaF(2:end,i+2) = num2cell(dF');
    deltaF_pos(2:end,i+2) = num2cell(dF_pos');
    %[position,stop,start] =checkForValidity(steepest,start,stop, numbStim);
end





