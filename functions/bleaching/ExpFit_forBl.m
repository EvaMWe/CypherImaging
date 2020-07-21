
function [coef] = ExpFit_forBl(X,Y)
X = X';
Y = Y';
ft=fittype('exp1');
coef=fit(X,Y,ft);
end



