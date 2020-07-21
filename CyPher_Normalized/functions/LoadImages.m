% This function will load tiff files from selected stack into Matlab
% output 3D Matrix

function imgStack = LoadImages (fpath, showImage)

filenames  = dir(fullfile(fpath,'*.tif'));
filenames = {filenames.name};
frameNumber=numel(filenames);
imageSize = size(imread(fullfile(fpath,filenames{1})));  %load one image to get the size;
imgStack = zeros(imageSize(1),imageSize(2),frameNumber);

for k=1:frameNumber
    d = filenames{k};
    f = fullfile(fpath,d);
    imgStack(:,:,k) = double(imread(f));        
end

if showImage == 1
    figure (1)
    img1 = imgStack(:,:,2);
    imshow(img1,'DisplayRange',[min(img1(:)) max(img1(:))])
    title ('initial frame')
    
    figure (2)
    img2 = imgStack(:,:,frameNumber -1);
    imshow(img2,'DisplayRange',[min(img2(:)) max(img2(:))])
    title ('last frame')
end

end