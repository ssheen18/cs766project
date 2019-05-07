% Takes a mask and an image and retrieves any connected components in the
% image that overlaps with pixels in the mask
%
% author: sheen2@wisc.edu

function beamImg = detectBeams(mask, orig)
    CC = bwconncomp(orig);
    beamImg = logical(zeros(size(orig, 1), size(orig, 2)));
    for i = 1:size(CC.PixelIdxList, 2)
        currCC = CC.PixelIdxList{1, i};
        if all(~mask(currCC)) == 0
            beamImg(currCC) = 1;
        end
    end

