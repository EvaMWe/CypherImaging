function Data = bleachCorrection(fitData)


fpath = uipickfiles (); % select experiments
nMeasure = length(fpath); %number of experiments

%%
%(2) for each selected measurement: load data stack, read out data,
% restore data
%-------------------------------
%preallocate struct
N = nMeasure;
Data = repmat(struct('indMeasure',1), N, 1 );
for measurement = 1:nMeasure;
    cyStack = LoadImages(fpath{measurement}, 0); %load image stack
    
    %------------------------------------------------------------------------
    % Find responding regions and get frame range to calculate the difference image;
    AverageTrace = permute(mean(mean(cyStack,1),2),[2,3,1]);   
    range = frameRange(AverageTrace(1,5:24));
    range = range + 5;
    if range(1) == 0
        range = range +1;
    end
    averageImg1 = mean(cyStack(:,:,range(1):range(2)),3,'native'); 
    averageImg2 = mean(cyStack(:,:,range(3):range(4)),3,'native');
    diffImg = imsubtract(averageImg1,averageImg2);
    diffImg(diffImg < 0) = 0;
    diffImg = wiener2(diffImg,[5,5]);
    imshow(diffImg,'DisplayRange',[min(diffImg(:)) max(diffImg(:))])
    
    %--------------------------------------------------------------------------
    % cell segmentation, data readout, trace restoration
    % input: struct, w, pth, radius, show figures
    [regionProperties,regionNb] = featureDetectionSb(diffImg, 2, 0.7, 5, 0);
    [restoredData, BG, regionNb] = ReadoutRestore (regionProperties, regionNb, cyStack);
    clear 'cyStack';
    Data(measurement).indMeasure = restoredData.dataMatrixofIndividualTraces;
    Data(measurement).averageTrace = restoredData.averageCurve;
    
    %---------------------------------------------------------------------------
    %correction for bleaching
    dataCorr = Data(measurement).indMeasure;
    lambda = fitData(2).curveCoef(2);
    for k = 1:regionNb
       dataCorr(k,:) = itDeconv (dataCorr(k,:), lambda);
    end    
    dataCorrMean = Data(measurement).averageTrace;
    dataCorrMean = itDeconv(dataCorrMean, lambda);
    
    Data(measurement).corrIndMeas = dataCorr;
    Data(measurement).corrAverage = dataCorrMean;     

end
