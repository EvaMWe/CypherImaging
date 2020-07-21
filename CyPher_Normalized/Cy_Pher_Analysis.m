% Cypher_AnalysationTool
% ---------------------------------------------------------------------------
% This is the main routine for the Cypher Software; It takes the raw files (multiple tiff files stored in a folder)
% by uipickfiles (function from the matlab exchanger)
% ---------------------------------------------------------------------------
% Desciption
% (1) data input by user interface.
%     a) experimental data, //you can select more than on file
%     b) bleaching data; you can select if you already have calcualted parameters or not
%          if not: select files for bleaching correction calculation
%          if yes: select parameter file
%     c) Enter directory for saving files  
%
% (2) find regions of interest (ROI)
%   
% (3) Normalization, Backgroundsubtraction, Bleach Correction
% 
% (4) Signal detection
%
% (5) Analysis of Traces

%
% (6) Save and export  

function Cy_Pher_Analysis()

%% (1) Data Input and save path


% a) Select experiments
%---------------------------------
    [dataFiles, dataPath] = uigetfile ('.tif','select experiment files', 'Multiselect', 'on'); 
    dataComplete = fullfile(dataPath,dataFiles);

% b) Input for Bleaching Correction
%    ------------------------------- 
    extraQtitle = 'Type of bleaching correction';
    extraQ = 'Do you want to use a blank measurement for bleaching correction?';
    extraAnsw = questdlg(extraQ,extraQtitle);
    if strcmp (extraAnsw, 'Yes')
        bl_flag = 'extra';
    elseif strcmp  (extraAnsw, 'No')
        bl_flag = 'intrinsic';
    else
        error('invalide input');
    end
    
    switch bl_flag
        case 'extra'
            bleachTitle = 'Load Lambda for bleaching correction';
            bleachQu = 'Do you want to load bleaching correction parameters?';
            QuAnsw = questdlg(bleachQu,bleachTitle);
            if strcmp(QuAnsw, 'Yes')
                [ParameterName, ParameterPath] = uigetfile('Prompt','select file containing lambda');
            elseif strcmp (QuAnsw,'No')
                [bleachingName, bleachingPath] =uigetfile ('.tif','select experiment for bleaching correction','Multiselect','on');
                bleachingComplete = fullfile(bleachingPath,bleachingName);
                saveTitle = 'You can save the fitting parameters for later usage';
                saveQuest = 'do you want to save parameters on your computer?';
                saveAnsw = questdlg(saveQuest,saveTitle);
                if strcmp(saveAnsw, 'Yes')
                    [Save_BleachingName, Save_BleachingPath] = uiputfile('*.mat', 'save: directory for bleaching parameters');
                end
            else
                error('invalide input');
            end
        otherwise
    end

% c) select the directory to save the results
[SaveName, SavePath] = uiputfile('.mat', 'select directory to save your files');

% d) name Excel-Sheet
[reportFile,reportPath] = uiputfile('.xlsx','Name Report File');

% e) enter a stimulation time
prompt = {'Enter frame number to top signal detection'};
frame = inputdlg(prompt);
frame = str2double(frame{1,1});

% f) enter stimulation number
prompt = {'Enter number of stimulations'};
nStim = inputdlg(prompt);
nStim = str2double(nStim{1,1});

if ~iscell(dataComplete)
    dataComplete = cellstr(dataComplete);
end
N = length(dataComplete); 

% g) OPTIONAL: enter frame number of first Stim
prompt = {'You can enter the frame number of first stimulation for upper accuracy'};
firstStim_ = inputdlg(prompt);
firstStim_ = str2double(firstStim_{1,1});

if isinteger(firstStim_)
    firstStim = firstStim_;
end

%%
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
    

    
    %% (6) correction for bleaching
    
    % get coefficient
    switch bl_flag
        case 'extra'
            switch QuAnsw
                case 'No'
                    if exist ('Save_BleachingName', 'var')
                        blData = GetFitCoeff_Multipage(bleachingComplete, Save_BleachingName, Save_BleachingPath);
                    else
                        blData = GetFitCoeff_Multipage(bleachingComplete);
                    end
                    QuAnsw = 'Calc';
                    
                case 'Yes'
                    blData = load(fullfile(ParameterPath, ParameterName));
                    
                otherwise
            end
    
            lambda = blData.Data(2).curveCoef(2);
            
        case 'intrinsic'
            meanCurve = mean(tracesSmth,1);
            cuttingWindow = 5;
            if exist('firstStim','var')
                [lambda, ~] = createBleachingCurve(meanCurve, frame, cuttingWindow, nStim, 1,firstStim);
            else
                [lambda, ~] = createBleachingCurve(meanCurve, frame, cuttingWindow, nStim, 1);
            end
    end
    
    % perform correction
    dataCorr = zeros(size(data));
    dataCorrSmth = zeros(size(data));
    for k = 1:regNb
        dataCorr(k,:) = itDeconv (data_BGsubt(k,:), lambda);
    end
    for k = 1:regNb
        dataCorrSmth(k,:) = itDeconv (tracesSmth(k,:),lambda);
    end
        
    
    %% (7) Normalization
    dataNorm = zeros(size(dataCorrSmth));
    for k = 1:regNb
        trace = dataCorrSmth(k,:);
        normTrace = norm_min_max(trace);
        dataNorm(k,:) = normTrace;
    end
    restored_Data(exp).normalized = dataNorm;
    %%calculate mean curve
    averageNorm = mean(dataNorm,1);
    variance = std(dataNorm,0,1);    
    
    sprintf('preprocessing of measurement%i succeeded',exp)
    
    %% (8) Signal detection
    %  (8a) Detection in mean curve:
           
    cuttingWindow = ceil(0.01*frame);
    if isnan(nStim)
        error('0 stimulations: no detection')
    else
        gradFilt = [-2 -1 0 1 2];
        SE = ones(1,cuttingWindow*2 +1);
        trace = averageNorm(1:frame);
        [starts, stops, dF,~,nStim,~] = getEdges(trace,gradFilt,SE,cuttingWindow,nStim,0);
    end
    
    %% (8b) Detection in traces from individual ROIs
    [deltaFCell, deltaFposCell] = detectStim_indiv(dataNorm, frame, cuttingWindow,starts,stops, nStim);
    statistic_indiv = statistics(deltaFCell);
    
    
    
    
 %----------DATA STORAGE---------------------------------------   
    %% data cell curves
        curvesCell = cell(3,length(averageNorm)+1);
        curvNam = {'mean curve of raw data','background trace','processed mean curve'};
        curvesCell(:,1) = num2cell(curvNam);
        curvesCell(1,2:end) = num2cell(mean(data));
        curvesCell(2,2:end) = num2cell(backgroundTrace);
        curvesCell(3,2:end) = num2cell(averageNorm);
        
     %% Name Rows: same for mean cell and individual cell
        RowNames = cell(nStim+1,1);
        RowNames{1,1} = 'StimulationNb';
        for stim = 2:nStim+1
            RowNames{stim,1} = sprintf('Stim_.%i',stim-1);
        end
        
        %% data cell mean curve
        meanDataCell = cell(length(starts)+1,4);
        varNames = {'stimulation start','stimulation stop','deltaF'};
        meanDataCell(1,2:4) = varNames;
        meanDataCell(:,1) = RowNames;
        meanDataCell(2:end,2) = num2cell(starts);
        meanDataCell(2:end,3) = num2cell(stops);
        meanDataCell(2:end,4) = num2cell(dF);
        
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
 
