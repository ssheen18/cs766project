% Performs vertical and horizontal medium filtering to eliminate remaining
% ties, stems, and bar lines.
%
% author: sheen2@wisc.edu
function result = disconnectStemAndNoteHead(img)
%     img = imread(imgPath);
    filteredImg = medfilt2(img, [1, 15]);
    filteredImg = medfilt2(filteredImg, [1, 15]);
    
    imwrite(filteredImg,'image_after_medium_filter.png');
    
    
    
    
    
    result = filteredImg;





