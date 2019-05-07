% Creates mask that contains pixels for creating beam image
%
% author: sheen2@wisc.edu
function beamMask = createBeamMask(noteStems, orig)
    CC = bwconncomp(noteStems);
    CCProp = zeros(size(CC.PixelIdxList, 2), 2);
    for i = 1:size(CC.PixelIdxList, 2)
        [rows, cols] = ind2sub([size(noteStems, 1), size(noteStems, 2)], CC.PixelIdxList{1, i});
        CCProp(i, 1) = min(rows);    % min y
        CCProp(i, 2) = max(rows);    % max y
        CCProp(i, 3) = median(cols); % median x
        CCProp(i, 4) = i;            % index
        CCProp(i, 5) = min(cols);    % min x
        CCProp(i, 6) = max(cols);    % max x
    end

    adjArray = eye(size(CCProp, 1));
    for i = 1:size(CCProp, 1)-1
        for j = i+1:size(CCProp, 1)
            if (CCProp(i, 1) <= CCProp(j, 2) && CCProp(i, 2) >= CCProp(j, 2)) ...
               || (CCProp(i, 2) >= CCProp(j, 1) && CCProp(i, 1) <= CCProp(j, 1)) ...
               || (CCProp(i, 1) >= CCProp(j, 1) && CCProp(i, 2) <= CCProp(j, 2)) ...
               || (CCProp(i, 1) <= CCProp(j, 1) && CCProp(i, 2) >= CCProp(j, 2))
               adjArray(i, j) = 1;
               adjArray(j, i) = 1;
            end
        end
    end
    
    noteStemGroups = zeros(size(adjArray, 1), 2);
    for i = 1:size(adjArray, 1)
        currArray = adjArray(i, :);
        currNoteStems = CCProp(find(currArray == 1), :);
        currNoteStems = sortrows(currNoteStems, 3);
        
        index = find(currNoteStems(:, 4) == i);
        
        if index - 1 > 0
            noteStemGroups(i, 1) = currNoteStems(index - 1, 4);
        end
        
        if index + 1 < size(currNoteStems, 1) + 1
            noteStemGroups(i, 2) = currNoteStems(index + 1, 4);
        end
    end
    
%     prop = regionprops(CC, 'Centroid');
%     centroids = cat(1, prop.Centroid);
%     text_str = cell(size(adjArray, 1), 1);
%     box_color = cell(1, size(adjArray, 1));
%     for i = 1:size(adjArray,1)
%        text_str{i} =  sprintf('%d', i);
%        box_color{i} = 'yellow';
%     end
%     
%     RGB = insertText(double(noteStems), centroids, text_str, 'FontSize', 18, ...
%         'BoxColor', box_color, 'BoxOpacity', 0.4, 'TextColor', 'white');
% 
%     figure; imshow(RGB);
    
    beamMask = logical(zeros(size(noteStems, 1), size(noteStems, 2)));
    for i = 1:size(noteStemGroups, 1)
       if noteStemGroups(i, 1) ~= 0
           leftBound = CCProp(noteStemGroups(i, 1), 6) + 1;
           rightBound = CCProp(i, 5) - 1;
           topBound = min(CCProp(i, 1), CCProp(noteStemGroups(i, 1), 1)) - 20;
           bottomBound = max(CCProp(i, 2), CCProp(noteStemGroups(i, 1), 2)) + 20;
           
           leftBound = round((leftBound + rightBound) / 2);
           intersections = [];
           for j = leftBound:rightBound
               isWhitePixel = 0;
               intersectionCount = 0;
               for k = topBound:bottomBound
                   if orig(k, j) == 1
                       isWhitePixel = 1;
                   else
                       if isWhitePixel == 1
                           intersectionCount = intersectionCount + 1;
                       end
                       isWhitePixel = 0;
                   end
               end
               intersections = [intersections; intersectionCount];
           end
           
           if size(intersections, 1) == 0
               intersections = [intersections; 0];
           end
           
           CCProp(i, 7) = mode(intersections);
           for j = leftBound:rightBound
               isWhitePixel = 0;
               whitePixelIndexY = -1;
               whitePixelIndexX = -1;
               
               index = zeros(CCProp(i, 7), 2);
               curr = 1;
               indexFound = 0;
               for k = topBound:bottomBound
                   if orig(k, j) == 1
                       isWhitePixel = 1;
                       whitePixelIndexY = k;
                       whitePixelIndexX = j;
                   else
                       if isWhitePixel == 1
                           if curr > CCProp(i, 7)
                               break;
                           end
                           
                           index(curr, 1) = whitePixelIndexY;
                           index(curr, 2) = whitePixelIndexX;
                           curr = curr + 1;
                       end
                       
                       isWhitePixel = 0;
                       whitePixelIndexY = -1;
                       whitePixelIndexX = -1;
                   end
                   
                   if k == bottomBound && curr > CCProp(i, 7)
                       indexFound = 1;
                   end
               end
               
               if indexFound == 1
                   for l = 1:size(index, 1)
                       beamMask(index(l, 1), index(l, 2)) = 1;
                   end
               end
           end
       end
       
       if noteStemGroups(i, 2) ~= 0
           leftBound = CCProp(i, 6) + 1;
           rightBound = CCProp(noteStemGroups(i, 2), 5) - 1;
           topBound = min(CCProp(i, 1), CCProp(noteStemGroups(i, 2), 1)) - 20;
           bottomBound = max(CCProp(i, 2), CCProp(noteStemGroups(i, 2), 2)) + 20;
           
           rightBound = round((leftBound + rightBound) / 2);
           intersections = [];
           for j = leftBound:rightBound
               isWhitePixel = 0;
               intersectionCount = 0;
               for k = topBound:bottomBound
                   if orig(k, j) == 1
                       isWhitePixel = 1;
                   else
                       if isWhitePixel == 1
                           intersectionCount = intersectionCount + 1;
                       end
                       isWhitePixel = 0;
                   end
               end
               intersections = [intersections; intersectionCount];
           end
           
           if size(intersections, 1) == 0
               intersections = [intersections; 0];
           end
           
           
           CCProp(i, 8) = mode(intersections);
           for j = leftBound:rightBound
               isWhitePixel = 0;
               whitePixelIndexY = -1;
               whitePixelIndexX = -1;
               index = zeros(CCProp(i, 8), 2);
               curr = 1;
               indexFound = 0;
               for k = topBound:bottomBound
                   if orig(k, j) == 1
                       isWhitePixel = 1;
                       whitePixelIndexY = k;
                       whitePixelIndexX = j;
                   else
                       if isWhitePixel == 1
                           if curr > CCProp(i, 8)
                               break;
                           end
                           
                           index(curr, 1) = whitePixelIndexY;
                           index(curr, 2) = whitePixelIndexX;
                           curr = curr + 1;
                       end
                       isWhitePixel = 0;
                       whitePixelIndexY = -1;
                       whitePixelIndexX = -1;
                   end
                   
                   if k == bottomBound && curr > CCProp(i, 8)
                       indexFound = 1;
                   end
               end
               
               if indexFound == 1
                   for l = 1:size(index, 1)
                       beamMask(index(l, 1), index(l, 2)) = 1;
                   end
               end
           end
       end
    end
