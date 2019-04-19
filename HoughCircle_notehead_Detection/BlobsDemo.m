function result = BlobsDemo(baseFileName)
%------------------------------------------------------------------------------------------------
% Demo to illustrate simple blob detection, measurement, and filtering.
% Requires the Image Processing Toolbox (IPT) because it demonstates some functions
% supplied by that toolbox, plus it uses the "coins" demo image supplied with that toolbox.
% If you have the IPT (you can check by typing ver on the command line), you should be able to
% run this demo code simply by copying and pasting this code into a new editor window,
% and then clicking the green "run" triangle on the toolbar.
% Running time = 7.5 seconds the first run and 2.5 seconds on subsequent runs.
% A similar Mathworks demo:
% http://www.mathworks.com/products/image/demos.html?file=/products/demos/shipping/images/ipexprops.html
% Code written and posted by ImageAnalyst, July 2009.  Updated April 2015 for MATLAB release R2015a
%------------------------------------------------------------------------------------------------
% function BlobsDemo()
% echo on;
% Startup code.
tic; % Start timer.
clc; % Clear command window.
% clearvars; % Get rid of variables from prior run of this m-file.
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

% Read in a standard MATLAB demo image of coins (US nickles and dimes, which are 5 cent and 10 cent coins)
% baseFileName = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\interrupted\w-06\symbol\p012.png';
% baseFileName = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\typeset-emulation\w-31\symbol\p010.png';

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

textFontSize = 14;	% Used to control size of "blob number" labels put atop the image.
labelShiftX = -7;	% Used to align the labels in the centers of the coins.
blobECD = zeros(1, numberOfBlobs);
% Print header line in the command window.
fprintf(1,'Blob #      Mean Intensity  Area   Perimeter    Centroid       Diameter\n');
% Loop over all blobs printing their measurements to the command window.
for k = 1 : numberOfBlobs           % Loop through all blobs.
	% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
	% directly into regionprops.  The way below works for all versions including earlier versions.)
props = regionprops(labeledImage, 'BoundingBox');
bb = [props.BoundingBox];
allWidths = bb(3:4:end);
%allWidths = blobMeasurements(k).width;
allHeights = bb(4:4:end);
%allHeights = blobMeasurements(k).height;
aspectRatio = [allWidths./allHeights ;  allHeights  ./ allWidths];
% disp('Aspect Ratio');
% disp(aspectRatio);
aspectRatios = max(aspectRatio, [], 1);
compactIndexes = find(aspectRatios < 0.5); % or whatever.

end
% Extract only those blobs with low aspect ratios.
binaryImage = ismember(labeledImage, compactIndexes);
imwrite(binaryImage,'test3_final.png');

% Display the image.


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
aspectRatios = max(aspectRatio, [], 1);
compactIndexes = find(aspectRatios < 3); % or whatever.

end

binaryImage_2 = ismember(eroded_staff_img, compactIndexes);
subplot(2, 1, 2);
imshow(binaryImage_2, []);
imwrite(binaryImage_2,'image_after_algorithm.png');

result = binaryImage_2;
%{
for k = 1 : numberOfBlobs           % Loop through all blobs.
	% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
	% directly into regionprops.  The way below works for all versions including earlier versions.)
props = regionprops(binaryImage, 'BoundingBox');
bb = [props.BoundingBox];
allWidths = bb(3:4:end)
%allWidths = blobMeasurements(k).width;
allHeights = bb(4:4:end)
%allHeights = blobMeasurements(k).height;
aspectRatio = [allWidths./allHeights ;  allHeights  ./ allWidths]
disp('Aspect Ratio');
disp(aspectRatio);
aspectRatios = max(aspectRatio, [], 1)
compactIndexes = find(aspectRatios < 3) % or whatever.

end

% Extract only those blobs with low aspect ratios.
binaryImage = ismember(binaryImage, compactIndexes);
% Display the image.
subplot(2, 1, 2);
imshow(binaryImage, []);
imwrite(binaryImage,'finalimg_12_secondloop.png');
%}
% Get a list of the blobs that meet our criteria and we need to keep.
% These will be logical indices - lists of true or false depending on whether the feature meets the criteria or not.
% for example [1, 0, 0, 1, 1, 0, 1, .....].  Elements 1, 4, 5, 7, ... are true, others are false.
%allowableIntensityIndexes = (allBlobIntensities > 150) & (allBlobIntensities < 220);
%allowableAreaIndexes = allBlobAreas < 2000; % Take the small objects.
% Now let's get actual indexes, rather than logical indexes, of the  features that meet the criteria.
% for example [1, 4, 5, 7, .....] to continue using the example from above.
%{
keeperIndexes = find(allowableIntensityIndexes & allowableAreaIndexes);
% Extract only those blobs that meet our criteria, and
% eliminate those blobs that don't meet our criteria.
% Note how we use ismember() to do this.  Result will be an image - the same as labeledImage but with only the blobs listed in keeperIndexes in it.
keeperBlobsImage = ismember(labeledImage, keeperIndexes);
% Re-label with only the keeper blobs kept.
labeledDimeImage = bwlabel(keeperBlobsImage, 8);     % Label each blob so we can make measurements of it
% Now we're done.  We have a labeled image of blobs that meet our specified criteria.
subplot(3, 3, 7);
imshow(labeledDimeImage, []);
axis image;
title('"Keeper" blobs (3 brightest dimes in a re-labeled image)', 'FontSize', captionFontSize);


for k = 1 : numberOfBlobs           % Loop through all keeper blobs.
	% Identify if blob #k is a dime or nickel.
	itsADime = allBlobAreas(k) < 2200; % Dimes are small.
	if itsADime
		% Plot dimes with a red +.
		plot(centroidsX(k), centroidsY(k), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
	else
		% Plot dimes with a blue x.
		plot(centroidsX(k), centroidsY(k), 'bx', 'MarkerSize', 10, 'LineWidth', 2);
	end
end


% Now use the keeper blobs as a mask on the original image.
% This will let us display the original image in the regions of the keeper blobs.
maskedImageDime = binaryImage; % Simply a copy at first.
maskedImageDime(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
subplot(3, 3, 8);
imshow(maskedImageDime);
axis image;
title('Only the 3 brightest dimes from the original image', 'FontSize', captionFontSize);


elapsedTime = toc;
% Alert user that the demo is done and give them the option to save an image.
message = sprintf('Done making measurements of the features.\n\nElapsed time = %.2f seconds.', elapsedTime);
message = sprintf('%s\n\nCheck out the figure window for the images.\nCheck out the command window for the numerical results.', message);
message = sprintf('%s\n\nDo you want to save the pseudo-colored image?', message);
reply = questdlg(message, 'Save image?', 'Yes', 'No', 'No');
% Note: reply will = '' for Upper right X, 'Yes' for Yes, and 'No' for No.
if strcmpi(reply, 'Yes')
	% Ask user for a filename.
	FilterSpec = {'*.PNG', 'PNG Images (*.png)'; '*.tif', 'TIFF images (*.tif)'; '*.*', 'All Files (*.*)'};
	DialogTitle = 'Save image file name';
	% Get the default filename.  Make sure it's in the folder where this m-file lives.
	% (If they run this file but the cd is another folder then pwd will show that folder, not this one.
	thisFile = mfilename('fullpath');
	[thisFolder, baseFileName, ext] = fileparts(thisFile);
	DefaultName = sprintf('%s/%s.tif', thisFolder, baseFileName);
	[fileName, specifiedFolder] = uiputfile(FilterSpec, DialogTitle, DefaultName);
	if fileName ~= 0
		% Parse what they actually specified.
		[folder, baseFileName, ext] = fileparts(fileName);
		% Create the full filename, making sure it has a tif filename.
		fullImageFileName = fullfile(specifiedFolder, [baseFileName '.tif']);
		% Save the labeled image as a tif image.
		imwrite(uint8(coloredLabels), fullImageFileName);
		% Just for fun, read image back into the imtool utility to demonstrate that tool.
		tifimage = imread(fullImageFileName);
		imtool(tifimage, []);
	end
end
%}


