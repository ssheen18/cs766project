% Detects note stems using dilation and overlap with note heads
%
% author: sheen2@wisc.edu
function result = detectNoteStems(candImg, blobImg)


    CC = bwconncomp(candImg);
    vertSE = strel('line', 20, 90);
    horiSE = strel('line', 10, 180);

    stemImg = zeros(size(candImg, 1), size(candImg, 2));

    props = regionprops(CC, 'BoundingBox');
    bb = [props.BoundingBox];
    allHeights = bb(4:4:end);
    meanHeight = mean(allHeights);
    madHeight = mad(allHeights);
    modifiedHeight = 0.6745*(allHeights - meanHeight) / madHeight;
    
    filteredIndex = modifiedHeight > 3.5;

%     for index = 1:size(allHeights, 2)
%         if percentDiff < 0.2
%             filteredIndex(1, index) = 1;
%         end
%     end
    
    for i = 1:size(CC.PixelIdxList, 2)
        if filteredIndex(1, i) == 1
           continue; 
        end
               
        img = zeros(size(candImg, 1), size(candImg, 2));
        img(CC.PixelIdxList{1, i}) = 1;
        dilatedImg = imdilate(img, vertSE);
        dilatedImg = imdilate(img, horiSE);
        
        overlap = dilatedImg & blobImg;
        if all(all(~overlap)) == 0
           stemImg = stemImg | img;
        end
    end
    
    
    result = stemImg;
    