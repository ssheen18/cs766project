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

evaluateResult(origImg, finalImgClosing);