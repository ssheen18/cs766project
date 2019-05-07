function result = preprocessImg(baseFileName, mode, threshold)


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

binaryImage = imread(fullFileName);

labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it

props = regionprops(labeledImage, 'BoundingBox');
bb = [props.BoundingBox];
allWidths = bb(3:4:end);
allHeights = bb(4:4:end);
aspectRatio = [allWidths./allHeights ;  allHeights  ./ allWidths];

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


binaryImage_2 = ismember(labeledImage, compactIndexes);
subplot(2, 1, 2);
imshow(binaryImage_2, []);
imwrite(binaryImage_2,'image_after_algorithm.png');

result = binaryImage_2;


