%This function returns the start adnd stop values from the individual
%curves that are nearest do the start and stop posiitons in the average
%curve
% input
% startstart = 1*n double array containing the startvalues of individual trace,
% n ist number of stim
% startAV = ''..start values of averaged curve
 % stopstop = ''..stop values of individial curve
 % stopAV = ''.. stop values of averaged curve

function [startTrue,stopTrue, logic] = getNearestNeighbor(startstart,startAV,stopstop,stopAV)

startMat = repmat(startstart',1,length(startAV));
stopMat = repmat(stopstop',1,length(stopAV));
refMat = repmat(startAV,length(startstart),1);
refMat2 = repmat(stopAV,length(stopstop),1);

subt = abs(startMat-refMat);
subt2 = abs(stopMat-refMat2);

[~,idx_start] =min(subt,[],1);
[~,idx_stop] = min(subt2,[],1);
start = startstart(idx_start);
stop = stopstop(idx_stop);

%check validity
logic = abs(start-startAV) <= 3;
startTrue = start(logic);
stopTrue = stop(logic);

end


