function [temp_start, temp_stop]  = checkForValidity_2vec(start,stop, numbStim)

if numbStim == 0
    error('no stimulations applied')
end

if length(start) > length(stop)
    meth = 1;
else
    meth = 2;
end

if length(start)>=numbStim
    temp_start = start(1:numbStim);
else
    temp_start = start;
    numbStim = length(start);
end

if length(stop)< numbStim
    temp_start = temp_start(1:length(stop));
    numbStim = length(stop);
end
temp_stop = stop(1:length(temp_start));

switch meth
    case 1
        [temp_start, temp_stop, start, stop]=removeExtraStarts(temp_start, temp_stop, numbStim, start,stop); 
        if length(start) < length(stop)
            [temp_start, temp_stop, ~,~] =removeExtraStops(temp_start, temp_stop, numbStim, stop,start);
        end
    case 2
        [temp_start, temp_stop, start, stop] =removeExtraStops(temp_start, temp_stop, numbStim, stop,start);
        if length(start) > length(stop)
            [temp_start, temp_stop,  ~,~]=removeExtraStarts(temp_start, temp_stop, numbStim, start,stop);
        end
end

end