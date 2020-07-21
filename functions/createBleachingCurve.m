function [lambda,positions] = createBleachingCurve(orig, range, cuttingWindow, nStim, varargin)
if nargin >= 5
    show = varargin{1};
else
    show = 1;
end

if nargin == 6
    firstStim = varargin{2};
end

if nStim == 0
    trace = orig(cuttingWindow:range);
    X = 1:length(trace);
    Y = trace;
else
    if exist('firstStim','var')
        [positions,nStim] = detectStim_forBl(orig, range, cuttingWindow,nStim,firstStim);
    else
        [positions,nStim] = detectStim_forBl(orig, range, cuttingWindow,nStim);
    end
    deltaF = positions.deltaF;
    starts = positions.start;
    stops = positions.stop;
    trace = positions.cuttedM;
    cumF = cumsum(deltaF);        
    %%creating the bleaching curve
    for n = 1:nStim+1
        if n == 1
            X = 1:starts(1,n);
            Y = trace(X);
        elseif n == nStim+1
            X = [X stops(1,n-1):length(trace)];
            Y = [Y trace(stops(1,n-1):length(trace)) + cumF(n-1)];
        else
            X = [X stops(1,n-1):starts(1,n)];
            Y = [Y trace(stops(1,n-1):starts(1,n)) + cumF(n-1)];
        end
    end
end

X=1:length(Y); %DELETE
coef = ExpFit_forBl(X,Y);


lambda = coeffvalues(coef);
lambda = lambda(1,2);

len_trace = length(X);
%len_trace = length(trace); %RELEASE


%form discrete for visualization
discrete= formDiscrete_forBl(coef, len_trace);

if show == 1
    figure('Name','created bleaching curve')
    plot(discrete)
    hold on    
    plot(trace);
end

%tailor positions to originl curve
cutWin = positions.cutWin;
positions.start=starts + cutWin;
positions.stop=stops + cutWin;
    



end

