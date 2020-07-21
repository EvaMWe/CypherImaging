%%
%----------------------------------------------------------------------------
% DATA EXTRACTION AND RESTORATION
% Calculate mean curve from normalized, background subtracted individual
% traces
% (1) select blank experiments (multiple selection is possible, average
% curve is then computed;
% (2) for each selected measurement: load data stack, read out data,
% restore data
% (3) calculate the fit curve; if more than one blank curve exists, an
% average curve is calculated
%-----------------------------------------------------------------------------

%%
%(1) select blank experiments (multiple selection is possible, average
% curve is then computed;
%----------------------------------------------------------------------------
function Data = GetFitCoeff_Multipage(varargin)

if nargin == 0 || nargin == 2   
    bName = uigetfiles ('MultiSelect', 'on'); % Messungen auswählen
elseif nargin == 1 || nargin == 3
    bName = varargin{1};  
else
    error ('variable input invalide');
end

if ~iscell(bName)
  bName = cellstr(bName); 
end

nMeasure = length(bName);



%%
%(2) for each selected measurement: load data stack, read out data,
% restore data
%-------------------------------
%preallocate struct
N = nMeasure;
Data = repmat(struct('averageTrace',1), N, 1 ); 
for measurement = 1:nMeasure
    fitStack = LoadMultipage(bName{measurement}, 0);
    AverageImage = mean(fitStack(:,:,2:5),3,'native'); %average image for segmentation
    [regionProperties,regionNb] = featureDetectionSb(AverageImage, 2, 0.7, 5, 0);
    [data, backgroundTrace, regionNb] = Readout(regionProperties, regionNb, fitStack);
    clearvars 'fitStack';
    %backgroundsubtraction
    dataBG = zeros(size(data));
    for i = 1:regionNb
        dataBG(i,:) = data(i,:)-backgroundTrace;
    end
    average = mean(dataBG,1);
    Data(measurement).averageTrace = average;    
end

%specify frame number if necessary
nFrames = length(Data(1).averageTrace);
    for measure = 1:nMeasure
        check = length(Data(measure).averageTrace);
        if check <= nFrames
            nFrames = check;
        end
    end
    

%%
% (3) calculate the fit curve; if more than one blank curve exists, an
% average curve is calculated
%----------------------------------------------------------------------------------
data = zeros(nMeasure, nFrames);
for measurement = 1:nMeasure
    temp = Data(measurement).averageTrace;
    data(measurement,:) = temp(1,1:nFrames);
end

if size(data,1) > 1
    blankCurve = mean(data);
else
    blankCurve = data(1,:);
end

fitTrace = ExpFit(blankCurve, 0);
discrExp = formDiscrete(fitTrace, nFrames,1);
curveCoef = coeffvalues(fitTrace);

Data(1).blankCurve = 'average over all selected measurements';
Data(2).blankCurve = blankCurve;
Data(1).fitTrace = 'fitted exp. funct';
Data(2).fitTrace = fitTrace;
Data(1).discrExp = 'discrete exp fkt for plotting';
Data(2).discrExp = discrExp;
Data(1).curveCoef = 'coefficients';
Data(2).curveCoef = curveCoef;

close all
if nargin == 2 
    SavePath = varargin{1};
    SaveName = varargin {2};
    save(fullfile(SavePath,SaveName),'Data');
elseif nargin == 3
    SavePath = varargin{2};
    SaveName = varargin {3};
    save(fullfile(SaveName,SavePath),'Data');
end

end


