%Same as Cy_PHer Analysis, but bleaching curev is created from experiment

function restored_Data = Cypher_Norm_inBl ()
%% (1) Data Input and save path


% a) Select experiments
%---------------------------------
[dataFiles, dataPath] = uigetfile ('.tif','select experiment files', 'Multiselect', 'on');
dataComplete = fullfile(dataPath,dataFiles);
% b) select the directory to save the results
[SaveName, SavePath] = uiputfile('.mat', 'select directory to save your files');

% c) name Excel-Sheet
[reportFile,reportPath] = uiputfile('.xlsx','Name Report File');

% d) enter a stimulation time
prompt = {'Enter frame number to top signal detection'};
frame = inputdlg(prompt);
frame = str2double(frame{1,1});

% e) enter stimulation number
prompt = {'Enter number of stimulations'};
nStim = inputdlg(prompt);
nStim = str2double(nStim{1,1});

% f) OPTIONAL: enter frame number of first Stim
prompt = {'You can enter the frame number of first stimulation for upper accuracy'};
firstStim_ = inputdlg(prompt);
firstStim_ = str2double(firstStim_{1,1});

if isinteger(firstStim_)
    firstStim = firstStim_;
end

if ~iscell(dataComplete)
    dataComplete = cellstr(dataComplete);
end
N = length(dataComplete); %number of experiments

restored_Data = repmat(struct('name',1),N,1);
for exp = 1:N
    if ~iscell(dataFiles)
        dataFiles = cellstr(dataFiles);
    end
    name = dataFiles{exp};
    restored_Data(exp).name = name;
    cyStack = LoadMultipage(dataComplete{exp}, 0);  %load image stack
    
    %% (2) Find ROIs;
    % a) prepare image for searching ROI
    range = 2:10;
    averageImg = mean(cyStack(:,:,range),3,'native');
    [regionProp,~] = featureDetectionSb(averageImg, 2, 1, 3, 0);
    
    %% (3)Readout and calculation of background trace
    regNb = length(regionProp);
    %restoration of traces //Normalization and Backgroundsubtraction
    [data, backgroundTrace, regionNb] = Readout(regionProp, regNb, cyStack);
    restored_Data(exp).rawdata = data;
    restored_Data(exp).backgroundTrace = backgroundTrace;
    
    %% (4) Subtraction of background
    %regionNb = size(data,1);
    data_BGsubt = zeros(size(data));
    for region = 1:regionNb
        traceTemp = data(region,:) - backgroundTrace;
        data_BGsubt(region,:) = traceTemp;
    end
    
    %% (5) smooth traces
    tracesSmth = zeros(size(data));
    regNb = regionNb;
    for i = 1:regNb
        tracesSmth(i,:) = smooth(data_BGsubt(i,:));
    end
    
    %% (6) creation of bleaching curve
    meanCurve = mean(tracesSmth,1);
    cuttingWindow = 5;
    if exist('firstStim','var')
        [lambda, positions] = createBleachingCurve(meanCurve, frame, cuttingWindow, nStim, 1,firstStim);
    else
         [lambda, positions] = createBleachingCurve(meanCurve, frame, cuttingWindow, nStim, 1);
    end
    %% (7) correction for bleaching
    dataCorr = zeros(size(data));
    dataCorrSmth = zeros(size(data));
    for k = 1:regNb
        dataCorr(k,:) = itDeconv (data_BGsubt(k,:), lambda);
    end
    for k = 1:regNb
        dataCorrSmth(k,:) = itDeconv (tracesSmth(k,:),lambda);
    end
    
    %% (8) Normalization
    dataNorm = zeros(size(dataCorrSmth));
    for k = 1:regNb
        trace = dataCorrSmth(k,:);
        normTrace = norm_min_max (trace);
        dataNorm(k,:) = normTrace;
    end
    
    %% calculate mean curve
    averageNorm = mean(dataNorm,1);
    variance = std(dataNorm,0,1);
  
    %% (10) Signal detection
    if nStim ~= 0
        starts = positions.start;
        stops = positions.stop;
        if length(stops) < nStim
            nStim = length(stops);
        end
        starts = starts(1,1:nStim);
        stops = stops(1,1:nStim);
        deltaF_avg = averageNorm(starts)-averageNorm(stops);
        
        %% data cell curves
        curvesCell = cell(3,length(averageNorm)+1);
        curvNam = {'mean curve of raw data','background trace','processed mean curve'};
        curvesCell(:,1) = num2cell(curvNam);
        curvesCell(1,2:end) = num2cell(mean(data));
        curvesCell(2,2:end) = num2cell(backgroundTrace);
        curvesCell(3,2:end) = num2cell(averageNorm);
        
        
        %% data cell mean curve
        meanDataCell = cell(length(starts)+1,4);
        varNames = {'stimulation start','stimulation stop','deltaF'};
        RowNames = cell(nStim+1,1);
        RowNames{1,1} = 'StimulationNb';
        for stim = 2:nStim+1
            RowNames{stim,1} = sprintf('Stim_.%i',stim-1);
        end
        meanDataCell(1,2:4) = varNames;
        meanDataCell(:,1) = RowNames;
        meanDataCell(2:end,2) = num2cell(starts);
        meanDataCell(2:end,3) = num2cell(stops);
        meanDataCell(2:end,4) = num2cell(deltaF_avg);
           
       
        %% calculation of individual ROIs
        cuttingWindow = 2;
        %parameters = detectStim(dataNorm, frame, cuttingWindow);
        [deltaFCell, deltaFposCell] = detectStim_indiv(dataNorm, frame, cuttingWindow,starts,stops, nStim);
        statistic_indiv = statistics(deltaFCell); 
        
        %% data cell statistic of individual synapsis
        varNames = {'mean dF', 'std dF', 'skewness dF', 'total numb of ROI', 'number of responders'};
        statisticCell = cell(nStim+1,6);
        statisticCell(:,1) = RowNames;
        statisticCell(1,2:end) = varNames;
        statisticCell(2:end,2) = num2cell(statistic_indiv.meanResp);
        statisticCell(2:end,3) = num2cell(statistic_indiv.stdResp);
        statisticCell(2:end,4) = num2cell(statistic_indiv.skewnessResp);
        statisticCell(2,5) = num2cell(statistic_indiv.numbTotal);
        statisticCell(2,6) = num2cell(statistic_indiv.numbResp);
        
     
        %% (11) create storage container // one per experiment
        results.rawData = data;
        results.normalized_data = dataNorm;
        results.averagedCurves = curvesCell;
        results.resultsMeanCurve =  meanDataCell;
        results.resultsIndiv_dF = deltaFCell;
        results.resultsIndiv_positionStim = deltaFposCell;
        results.statisticsIndiv = statisticCell;
        save(replace(fullfile(SavePath,dataFiles{exp}),'.tif',''),'results');
        
        %% (12) save results as excel file // one per experiment
        filename = replace(dataFiles{exp},'.tif',sprintf('_%s',reportFile));
        export2Excel_cypher(results,reportPath,filename)
    end
end    
end
