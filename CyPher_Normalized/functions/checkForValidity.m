function [temp_steep,temp_stop,temp_start] =checkForValidity(steepest,start,stop, numbStim)

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
%         if length(stop) < numbStim
%             numbStim = length(stop)
        temp_stop = stop(1:numbStim);
        temp_start = start(1:numbStim);
        delta_low = temp_steep - temp_start;
        delta_high = temp_stop - temp_start;
    end   
end
end