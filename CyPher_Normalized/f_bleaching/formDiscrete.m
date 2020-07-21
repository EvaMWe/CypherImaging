%This is a function that forms a disrete function out of an cfit object or
%a continuous funtion
% Input: fitObj: Object or funtion
%        X_length: Length of X
%        show: show control image, 1 = yes
% Output: discFkt: vector containing values of discrete function

function[discFkt] = formDiscrete(fitObj, X_length, show)

if isobject(fitObj)
    X = 1:1:X_length;
    discFkt = fitObj(X); 
    
    if show == 1
        plot(X,discFkt)
    end
    
else
    
    %hier kommt dann noch die Möglichkeit aus einer Funktion und den
    %Koeffizienten eine diskrete Funktion zu schreiben
    
    discFkt = 1.005*exp(b*x);
    
end


end
