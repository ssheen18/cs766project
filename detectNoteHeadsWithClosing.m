% Detects note heads using closing
%
% author: sheen2@wisc.edu
function result = detectNoteHeadsWithClosing(img)


    % loading the image to process
%     img = imread('image_after_medium_filter.png');
    % img = imread('CVCMUSCIMA_SR\CvcMuscima-Distortions\thickness-ratio\w-11\symbol\p008.png');
    % figure; imshow(img);

    se30Deg = createEllipticalStructuringElement(pi*(1/3));
    seNeg30Deg = createEllipticalStructuringElement(-1*pi*(1/3));

    img = imclose(img, se30Deg);
    % figure; imshow(img);

    img = imclose(img, seNeg30Deg);
    % figure; imshow(img);
    % 
    imwrite(img, 'image_after_closing.png');

    labeledImage = bwlabel(img, 8);  
    props = regionprops(labeledImage, 'BoundingBox');
    bb = [props.BoundingBox];
    allWidths = bb(3:4:end);
    allHeights = bb(4:4:end);

    compactIndexes = intersect(find(allWidths < 50), find(allHeights < 50));

    binaryImage = ismember(labeledImage, compactIndexes);
    imwrite(binaryImage,'note_heads_detected_with_closing.png');

    result = binaryImage;