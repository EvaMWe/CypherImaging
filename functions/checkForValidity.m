% this function checks the proper sequence of start-steepest-stop 
% checks the condition that the distance between steep and start is lower
% that the distance between stop and start;
% if the condition is not met at one or more positions,the corresponding
% values are taken out one in a row (while condition until the condition is
% fulfilled)
%steepest: 1xn vector containing the detected stimuli from analyseTrace
%temp_steep: 1xnumbStim containing the adjusted stimuli
function [temp_steep,temp_stop,temp_start, numbStim] =checkForValidity(steepest,start,stop, numbStim)

if length(steepest) < numbStim
    numbStim = length(steepest);
end

temp_steep = steepest(1:numbStim);
temp_stop = stop(1:numbStim);
temp_start = start(1:numbStim);

%delta steep -start !< stop -start
delta_low = temp_steep - temp_start;
delta_high = temp_stop - temp_start;

check  = 1;
while check == 1
    logic = delta_low < delta_high;
    idx = find(logic == 0);
    if isempty(idx)
        check = 0;
        continue        
    else
        start(idx(1)+1) = [];
        stop(idx(1)) = [];
        if numbStim > length(stop)
            numbStim = length(stop);
            temp_steep = temp_steep(1:numbStim);
        end
        temp_stop = stop(1:numbStim);
        temp_start = start(1:numbStim);
        delta_low = temp_steep - temp_start;
        delta_high = temp_stop - temp_start;
    end   
end
end