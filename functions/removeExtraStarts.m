

% condition 2: start(i+1) > stop(i)
% removes "extrastarts"

function [temp_start, temp_stop, start, stop]=removeExtraStarts(temp_start, temp_stop, numbStim, start, stop) 
check = 1;
while check == 1
    logic = temp_start(2:end) <= temp_stop(1:end-1);
    if sum(logic) == 0
        check = 0;
        continue
    else
        start(find(logic,1,'first')+1) = [];
        if length(start) >= numbStim
            temp_start = start(1:numbStim);
        else
            temp_start = start;
            temp_stop = stop(1:length(start));
        end
    end
end