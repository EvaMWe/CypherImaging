function stats = statistics(deltaF)

array = cell2mat(deltaF(2:end,2:end));
synTotal = size(array,2);
numbStim = size(array,1);
% conditions: first stim + at least 50% responders
log1 = array(1,:) ~= 0;
log2 = sum((array ~= 1),1) >= floor(0.5*numbStim);

idx = find(log1 + log2 == 2);

synResp = length(idx);
array2 = array(:,idx);

%statistics
meanResp = mean(array2,2);
stdResp = std(array2,0,2);
skewResp = skewness(array2,1,2);
totaldF = mean(sum(array2,1),2);


stats.dataResponders = array2;
stats.meanResp = meanResp;
stats.stdResp = stdResp;
stats.skewnessResp = skewResp;
stats.totalDelta = totaldF;
stats.numbResp =synResp;
stats.numbTotal = synTotal;

end
