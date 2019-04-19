% Main program for performing music symbol segmentation.
%
% author: sheen2@wisc.edu

imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\interrupted\w-06\symbol\p012.png';
% imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\staffline-y-variation-v1\w-23\symbol\p006.png';
% imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\typeset-emulation\w-31\symbol\p010.png';

% staffImgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\interrupted\w-06\gt\p012.png';

preprocessedImage = BlobsDemo(imgPath);

% detecting noteheads using closing
filteredImg = applyMedianFilter(preprocessedImage, 'both');
% imshow(filteredImg);

finalImgClosing = detectNoteHeadsWithClosing(filteredImg);

figure; imshow(finalImgClosing);

% detecting stems using orientation, roundness, and noteheads
origImg = imread(imgPath);

vertFilteredImg = applyMedianFilter(origImg, 'vert');

finalImgOpening = detectNoteHeadsWithOpening(vertFilteredImg);

finalImg = finalImgClosing | finalImgOpening;

noteStemCandidateImg = findNoteStemCandidates(vertFilteredImg);

noteStemImg = detectNoteStems(noteStemCandidateImg, finalImg);

beamMask = createBeamMask(noteStemImg, origImg);
beamImg = detectBeams(beamMask, origImg);

evaluateResult(origImg, finalImgClosing);

img_list = {'Image with Noteheads','Image with Stems'};
Es = cell(2,1)
for i = 1:length(img_list)
    img = imread([img_list{i} '.png']);
    [center radius img2]= centroids_calculation(img);
    %save('centroid_properties', 'center','radius');
    Es{i} = [center radius]
    imwrite(img2, ['centroids_' img_list{i} '.png']);
end

Es_Notes = Es{1}
Es_Stems = Es{2}
save('centroid_properties_Noteheads', 'Es_Notes');
save('centroid_properties_Stems', 'Es_Stems');

[~,idx] = sort(Es_Notes(:,2)); % sort just the first column
sortedmat_Notes = Es_Notes(idx,:);   % sort the whole matrix using the sort indices
    
save('sorted_centroid_properties_Noteheads', 'sortedmat_Notes');

[~,idx] = sort(Es_Stems(:,2)); % sort just the first column
sortedmat_Stems = Es_Stems(idx,:);   % sort the whole matrix using the sort indices
    
save('sorted_centroid_properties_Noteheads', 'sortedmat_Stems');

%Find the closest stem centroid for every note centroid
[m n k] = size(Es_Notes)
minimum = zeros(m,2)
for i=1:m
    indexes = find(sortedmat_Stems(:,1)< (sortedmat_Notes(i,1)+100) | sortedmat_Stems(:,1)> (sortedmat_Notes(i,1)-100))
    minimum(i,1) = sortedmat_Stems(1,1)
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

img_notes = imread('Image with Noteheads.png')
cc = bwconncomp(img_notes); 
stats = regionprops(cc,'Centroid'); 
center_notes = cat(1,stats.Centroid);

[~,idx] = sort(center_notes(:,2)); % sort just the first column
sortedmat_center_notes = center_notes(idx,:);   % sort the whole matrix using the sort indices
save('sorted_centers_notes', 'sortedmat_center_notes');
for i=1:length(center_notes)
    idx3 = find(sortedmat_center_notes(i,1) == minimum(i,2))
end
binaryimage = ismember(img_notes,idx3)
imwrite(double(binaryimage), 'binaryimage.png');


%Find the centers of the original notes image and retain the relevant notes
img_stems = imread('Image with Stems.png')
cc_2 = bwconncomp(img_stems); 
stats = regionprops(cc_2,'Centroid'); 
center_stems = cat(1,stats.Centroid);
[~,idx] = sort(center_stems(:,2)); % sort just the first column
sortedmat_center_stems = center_stems(idx,:);   % sort the whole matrix using the sort indices
save('sorted_centers_stems', 'sortedmat_center_stems');

unique_min = unique(minimum(:,3))
k=1
for i=1:length(center_stems)
    idx2 = find(sortedmat_center_stems(i,1) == unique_min(:))
    if(isempty(idx2)==0)
        index(k) = idx2;
        k = k+1;
    end
end
binaryimage_2 = ismember(img_stems,index);  
imwrite(double(binaryimage_2), 'binaryimage_2.png');

%Create the mask
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
                      
    
