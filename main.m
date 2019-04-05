% Main program for performing music symbol segmentation.
%
% author: sheen2@wisc.edu

% imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\interrupted\w-06\symbol\p012.png';
% imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\staffline-y-variation-v1\w-23\symbol\p006.png';
imgPath = 'CVCMUSCIMA_SR\CvcMuscima-Distortions\typeset-emulation\w-31\symbol\p010.png';
preprocessedImage = BlobsDemo(imgPath);

filteredImg = disconnectStemAndNoteHead(preprocessedImage);
% imshow(filteredImg);


finalImg = detectNoteHeadsWithClosing(filteredImg);

imshow(finalImg);