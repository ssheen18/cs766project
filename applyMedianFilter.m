% Performs vertical and/or horizontal median filtering to eliminate
% remaining ties, stems, and bar lines.
%
% author: sheen2@wisc.edu
function result = applyMedianFilter(img, mode)
    if strcmp(mode, 'vert') == 1
        filteredImg = medfilt2(img, [15, 1]);
    elseif strcmp(mode, 'horiz') == 1
        filteredImg = medfilt2(filteredImg, [1, 15]);
    else
        filteredImg = medfilt2(img, [15, 1]);
        filteredImg = medfilt2(filteredImg, [1, 15]);
    end

    imwrite(filteredImg,'image_after_medium_filter.png');

    result = filteredImg;





