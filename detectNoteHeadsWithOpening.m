% Detects note heads using opening
%
% author: sheen2@wisc.edu
function result = detectNoteHeadsWithOpening(img)

    se = strel('disk',5);

    img = imopen(img, se);
    % figure; imshow(img);

    imwrite(img, 'image_after_opening.png');

    result = img;