function img_stems = BlobsDemo(baseFileName)
clc; % Clear command window.

fprintf('Detecting the stems...\n');
binaryImage = imread(baseFileName);

binaryImage = imfill(binaryImage, 'holes');

labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it

% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurements = regionprops(labeledImage, binaryImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);

% Loop over all blobs printing their measurements to the command window.
for k = 1 : numberOfBlobs           % Loop through all blobs.
    
props = regionprops(labeledImage, 'BoundingBox');
bb = [props.BoundingBox];
allWidths = bb(3:4:end);
allHeights = bb(4:4:end);
compactIndexes = intersect(find(allWidths < 12), find(allHeights > 16));

end
% Extract only those blobs with low aspect ratios.
binaryImage = ismember(labeledImage, compactIndexes);
imwrite(binaryImage,'img_stems_2.png');

img_stems = binaryImage;
%For p012.png
%img_stems: 12, 19
%img_stems_2(good): 12, 16
%img_stems_3:10, 5

%For p008.png
%12, 10
