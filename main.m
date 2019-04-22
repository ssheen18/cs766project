% Main program for performing music symbol segmentation.
%
% author: sheen2@wisc.edu
% author: akalyanaram2@wisc.edu
% author: kalyanarama3@wisc.edu

imgPath = 'p012.png';
imgPathGroundTruth = 'ground_truth_p012.png';
% imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\staffline-y-variation-v1\w-23\symbol\p006.png';
% imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\typeset-emulation\w-31\symbol\p010.png';

% staffImgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\interrupted\w-06\gt\p012.png';

preprocessedImage = BlobsDemo(imgPath);

% detecting noteheads using closing
filteredImg = applyMedianFilter(preprocessedImage, 'both');
% imshow(filteredImg);

%HOUGH CIRCLE
img = filteredImg;
[centers, radii] = find_circles(img, [3.5,10]);

circle_img = hough_circles_draw(img, centers, radii);
imwrite(im2double(circle_img), 'hough_circles_p012.png');

finalImgClosing = detectNoteHeadsWithClosing(filteredImg);
figure; imshow(finalImgClosing);
imwrite(im2double(finalImgClosing), 'closing noteheads.png');
[height width] = size(finalImgClosing)

mask = zeros(height, width, 'uint8');

hough_circle_img = hough_circles_draw(mask, centers, radii);
imwrite(im2double(hough_circle_img),'hough_circles_drawn_p012.png');



% Get size of existing image A.
[rowsA colsA] = size(finalImgClosing);
% Get size of existing image B.
[rowsB colsB] = size(hough_circle_img);
% See if lateral sizes match.
if rowsB ~= rowsA || colsA ~= colsB
% Size of B does not match A, so resize B to match A's size.
hough_circle_img = imresize(hough_circle_img, [rowsA colsA]);
end

redChannel = hough_circle_img(:, :, 1);
hough_circle_img = im2bw(redChannel, 0.5);
imwrite(im2double(hough_circle_img),'hough_circles_drawn_final.png');

%{
labeledImage = bwlabel(hough_circle_img, 8);  
props = regionprops(labeledImage, 'BoundingBox');
bb = [props.BoundingBox];
allWidths = bb(3:4:end);
allHeights = bb(4:4:end);

compactIndexes = intersect(find(allWidths < 16), find(allHeights < 16));

binaryImage = ismember(labeledImage, compactIndexes);
imwrite(binaryImage,'Hough_circles_final.png');

hough_circle_img = binaryImage;
%}
%APPEND CLOSING AND HOUGH CIRCLE IMAGES

hough_circle_and_closing = hough_circle_img | finalImgClosing;
imwrite(im2double(hough_circle_and_closing),'HOUGH_CIRCLE_AND_CLOSING.png');

%DETECTING STEMS ON THE APPENDED IMAGE
% detecting stems using orientation, roundness, and noteheads
origImg = imread(imgPath);
groundTruthImg = im2bw(imread(imgPathGroundTruth), 0.5);

vertFilteredImg = applyMedianFilter(origImg, 'vert');

%finalImgOpening = detectNoteHeadsWithOpening(vertFilteredImg);

%finalImg = finalImgClosing | finalImgOpening;
%finalImg = finalImgClosing;

noteStemCandidateImg = findNoteStemCandidates(vertFilteredImg);
imwrite(noteStemCandidateImg,'Image with Candidate Stems.png');


noteStemImg = detectNoteStems(noteStemCandidateImg, hough_circle_and_closing);
imwrite(noteStemImg,'Image with Stems.png');



img_list = {'HOUGH_CIRCLE_AND_CLOSING','Image with Candidate Stems'};
Es = cell(2,1)
for i = 1:length(img_list)
    img = imread([img_list{i} '.png']);
    %img = im2uint8(img);
    [center radius img2]= centroids_calculation(img);
    %save('centroid_properties', 'center','radius');
    Es{i} = [center radius]
    imwrite(img2 , ['centroids_' img_list{i} '.png']);
end

Es_Notes = Es{1}
Es_Stems = Es{2}
%save('centroid_properties_Noteheads', 'Es_Notes');
%save('centroid_properties_Stems', 'Es_Stems');

[~,idx] = sort(Es_Notes(:,2)); % sort just the first column
sortedmat_Notes = Es_Notes(idx,:);   % sort the whole matrix using the sort indices
    
%save('sorted_centroid_properties_Noteheads', 'sortedmat_Notes');

[~,idx] = sort(Es_Stems(:,2)); % sort just the first column
sortedmat_Stems = Es_Stems(idx,:);   % sort the whole matrix using the sort indices
    
%save('sorted_centroid_properties_Noteheads', 'sortedmat_Stems');

%Find the closest stem centroid for every note centroid
[m n k] = size(Es_Notes)
minimum = zeros(m,2)
for i=1:m
    indexes = find(sortedmat_Stems(:,1)< (sortedmat_Notes(i,1)+20) & sortedmat_Stems(:,1)> (sortedmat_Notes(i,1)-20))
    minimum(i,1) = realmax();
    for j=1:length(indexes)
        difference = abs(sortedmat_Notes(i,1) - sortedmat_Stems(j,1))
        if(difference<minimum(i,1))
            minimum(i,1) = difference
            minimum(i,2) = sortedmat_Notes(i,1)
            minimum(i,3) = sortedmat_Stems(j,1)
        end
    end
end

%Find the centers of the original notes image and retain the relevant notes

%img_notes = imread('Image with Noteheads.png')
cc = bwconncomp(hough_circle_and_closing); 
stats = regionprops(cc,'Centroid'); 
center_notes = cat(1,stats.Centroid);

[~,idx] = sort(center_notes(:,2)); % sort just the first column
sortedmat_center_notes = center_notes(idx,:);   % sort the whole matrix using the sort indices
%save('sorted_centers_notes', 'sortedmat_center_notes');
for i=1:length(center_notes)
    idx3 = find(sortedmat_center_notes(i,1) == minimum(i,2))
end
binaryimage = ismember(hough_circle_and_closing,idx3)
imwrite(double(binaryimage), 'binaryimage.png');


%Find the centers of the original notes image and retain the relevant notes
%img_stems = imread('Image with Stems.png')
cc_2 = bwconncomp(noteStemCandidateImg); 
stats = regionprops(cc_2,'Centroid'); 
center_stems = cat(1,stats.Centroid);
[~,idx] = sort(center_stems(:,2)); % sort just the first column
sortedmat_center_stems = center_stems(idx,:);   % sort the whole matrix using the sort indices
%save('sorted_centers_stems', 'sortedmat_center_stems');

unique_min = unique(minimum(:,3))
k=1
for i=1:length(center_stems)
    idx2 = find(sortedmat_center_stems(i,1) == unique_min(:))
    if(isempty(idx2)==0)
        index(k) = idx2;
        k = k+1;
    end
end
binaryimage_2 = ismember(noteStemCandidateImg,index);  
imwrite(double(binaryimage_2), 'binaryimage_2.png');

% finalStemImg = noteStemImg | binaryimage_2;
finalStemImg = noteStemImg;

%Create the mask
%{
img_list = {'binaryimage','binaryimage_2'};
[height width] = size(binaryimage)
mask = zeros(height,width);
for i = 1:length(img_list)
    img = imread([img_list{i} '.png']);
    for j=1:height
        for k=1:width
            if(img(j,k)~=0)
                mask(j,k)=1;
            end
        end
    end
end
imwrite(double(mask), 'mask.png');
%}

beamMask = createBeamMask(finalStemImg, origImg);
beamImg = detectBeams(beamMask, origImg);
imwrite(beamImg,'Image with Beams.png');


allComp_Img = detectBeams(hough_circle_and_closing, origImg) | detectBeams(noteStemImg, origImg) | beamImg;
imwrite(double(allComp_Img), 'FinalImage.png');
   
evaluateResult(groundTruthImg, allComp_Img);
    
