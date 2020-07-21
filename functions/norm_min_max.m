%
% CAlculate the normalized trace: normalized to the first plateau

function normTrace = norm_min_max (trace)

[Mini,~] = Minimum_median(trace,3,'Dimension',2,'Type','number');
Maxi = Maximum_median(trace,3,'Dimension',2,'Type','number');

normTrace = (trace - Mini)/(Maxi-Mini);

end
