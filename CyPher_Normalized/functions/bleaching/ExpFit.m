
function [coef] = ExpFit(RawCurve, show)
SmthCurve = smooth(RawCurve);
X = (1:1:length(SmthCurve))';
Y = SmthCurve;
ft=fittype('exp1');
coef=fit(X,Y,ft);

    if show == 1
        plot(coef, X, RawCurve)
    end

end



