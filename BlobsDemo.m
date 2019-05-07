function result = BlobsDemo(baseFileName, mode, threshold)
%------------------------------------------------------------------------------------------------
% Filters out bar lines, braces, and ties using aspect ratios.
%
% Original code written and posted by ImageAnalyst, July 2009 from 
% https://www.mathworks.com/matlabcentral/fileexchange/25157-image-segmentation-tutorial
% Updated April 2015 for MATLAB release R2015a
%
% Modified by sheen2@wisc.edu, akalyanaram2@wisc.edu, kalyanarama3@wisc.edu
%------------------------------------------------------------------------------------------------

% Startup code.
tic; % Start timer.
clc; % Clear command window.
fprintf('Running BlobsDemo.m...\n'); % Message sent to command window.
workspace; % Make sure the workspace panel with all the variables is showing.
imtool close all;  % Close all imtool figures.
format long g;
format compact;
captionFontSize = 14;

% Check that user has the Image Processing Toolbox installed.
hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% User does not have the toolbox installed.
	message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
	if strcmpi(reply, 'No')
		% User said No, so exit.
		return;
	end
end


folder = fileparts(which(baseFileName)); % Determine where demo folder is (works with all versions).
fullFileName = fullfile(folder, baseFileName);
if ~exist(fullFileName, 'file')
	% It doesn't exist in the current folder.
	% Look on the search path.
	if ~exist(baseFileName, 'file')
		% It doesn't exist on the search path either.
		% Alert user that we can't find the image.
		warningMessage = sprintf('Error: the input image file\n%s\nwas not found.\nClick OK to exit the demo.', fullFileName);
		uiwait(warndlg(warningMessage));
		fprintf(1, 'Finished running BlobsDemo.m.\n');
		return;
	end
	% Found it on the search path.  Construct the file name.
	fullFileName = baseFileName; % Note: don't prepend the folder.
end
% If we get here, we should have found the image file.
binaryImage = imread(fullFileName);
% ========== IMPORTANT OPTION ============================================================
% Use < if you want to find dark objects instead of bright objects.
%   binaryImage = originalImage < thresholdValue; % Dark objects will be chosen if you use <.

% Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
binaryImage = imfill(binaryImage, 'holes');

% Show the threshold as a vertical red bar on the histogram.
hold on;
maxYValue = ylim;

% Display the binary image.
subplot(3, 3, 3);
imshow(binaryImage); 
title('Binary Image, obtained by thresholding', 'FontSize', captionFontSize); 

% Identify individual blobs by seeing which pixels are connected to each other.
% Each group of connected pixels will be given a label, a number, to identify it and distinguish it from the other blobs.
% Do connected components labeling with either bwlabel() or bwconncomp().
labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it
% labeledImage is an integer-valued image where all pixels in the blobs have values of 1, or 2, or 3, or ... etc.
subplot(3, 3, 4);
imshow(labeledImage, []);  % Show the gray scale image.
title('Labeled Image, from bwlabel()', 'FontSize', captionFontSize);

% Let's assign each blob a different color to visually show the user the distinct blobs.
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
% coloredLabels is an RGB image.  We could have applied a colormap instead (but only with R2014b and later)
subplot(3, 3, 5);
imshow(coloredLabels);
imwrite(coloredLabels, 'coloredblobs.png');
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
caption = sprintf('Pseudo colored labels, from label2rgb().\nBlobs are numbered from top to bottom, then from left to right.');
title(caption, 'FontSize', captionFontSize);

% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
blobMeasurements = regionprops(labeledImage, binaryImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);

% bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
% Plot the borders of all the coins on the original grayscale image using the coordinates returned by bwboundaries.
subplot(3, 3, 6);
imshow(binaryImage);
title('Outlines, from bwboundaries()', 'FontSize', captionFontSize); 
axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
hold on;
boundaries = bwboundaries(binaryImage);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end
hold off;



staff_struct_element = strel('line', 11, 90);
dilated_staff_img = imdilate(labeledImage, staff_struct_element);

staff_struct_element = strel('line', 11, 90);
eroded_staff_img = imerode(dilated_staff_img, staff_struct_element);
imwrite(eroded_staff_img, 'image_after_dilation_erosion.png');

for k = 1 : numberOfBlobs           % Loop through all blobs.
	% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
	% directly into regionprops.  The way below works for all versions including earlier versions.)
props = regionprops(eroded_staff_img, 'BoundingBox');
bb = [props.BoundingBox];
allWidths = bb(3:4:end);
%allWidths = blobMeasurements(k).width;
allHeights = bb(4:4:end);
%allHeights = blobMeasurements(k).height;
aspectRatio = [allWidths./allHeights ;  allHeights  ./ allWidths];
% disp('Aspect Ratio');
% disp(aspectRatio);
if strcmp(mode, 'width') == 1
    aspectRatios = aspectRatio(1, :);
elseif strcmp(mode, 'height') == 1
    aspectRatios = aspectRatio(2, :);
else
    aspectRatios = max(aspectRatio, [], 1);
end

if size(threshold, 2) ~= 1
    compactIndexes = intersect(find(aspectRatios > threshold(1, 1)), find(aspectRatios < threshold(1, 2))); % or whatever.
else
    compactIndexes = find(aspectRatios < threshold); % or whatever.
end

end

binaryImage_2 = ismember(eroded_staff_img, compactIndexes);
subplot(2, 1, 2);
imshow(binaryImage_2, []);
imwrite(binaryImage_2,'image_after_algorithm.png');

result = binaryImage_2;
