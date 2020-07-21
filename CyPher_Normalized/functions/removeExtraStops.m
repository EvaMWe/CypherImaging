% condition 1: start < stop
% removes "extrastops"

function [temp_start, temp_stop, start, stop]=removeExtraStops(temp_start, temp_stop, numbStim, stop, start) 

check  = 1;
while check == 1
    logic = temp_start >= temp_stop;
    %log_idx = logic == 1;
    if sum(logic) == 0
        check = 0;
        continue
    else
        stop(find(logic,1,'first')) = [];
        if length(stop) >= numbStim
            temp_stop = stop(1:numbStim);
        else            
            temp_stop = stop;
            temp_start = start(1:length(stop)); % adapt length start to the new length of stop
        end
    end
end
end