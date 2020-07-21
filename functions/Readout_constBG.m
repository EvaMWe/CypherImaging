%
%input: image stack: containing the frames
%       region properties: containing the coordinates for region of
%       interest
%output: restored traces from individual region of interest (normalized and
%        background subtracted)
%        Normalization to the unstimulated fluorescence value at the
%        beginning of the experiment

function [data, backgroundTrace, regionNb] = Readout_constBG(pixelIdx, regionNb, stack)

%calculation of the background trace
frameNb=size(stack,3);
backgroundTrace = zeros(1,10);
for frame = 1:10
    img = stack(:,:,frame);
    background_value = BackSubst_Gauss(img,0);
    backgroundTrace(frame) = background_value;
end
BGVal = mean(backgroundTrace,2);
backgroundTrace = zeros(1,frameNb);
backgroundTrace(backgroundTrace == 0) = BGVal;

%backgroundTrace = smooth(backgroundTrace)';

%readout data
data = zeros(regionNb,frameNb);
for frame = 1:frameNb
    img = stack(:,:,frame);
    for region = 1:regionNb
        pxl = pixelIdx(region,1).PixelIdxList;
        if pxl == 1
            continue
        end
        data(region,frame) = mean(img(pxl));
    end
end

data = data(any(data,2),:);
regionNb = size(data,1);

% restoration of individual traces and calculation of the average curve
%preallocate struct
%N = regionNb;
%restoredData = repmat(struct('restoredTrace',1), N, 1 );

disp 'read-out finished'
end