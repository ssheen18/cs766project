function result = findNoteStemCandidates(vertFilteredImg)

    % finding round object
    % (https://www.mathworks.com/help/images/identifying-round-objects.html)
    vertLineSegImg = zeros(size(vertFilteredImg, 1), size(vertFilteredImg, 2));
    [B,L] = bwboundaries(vertFilteredImg,'noholes');
    stats = regionprops(L,'Area');
    threshold = 0.3;
    for k = 1:length(B)

      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};

      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));

      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;

      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;

      % mark objects above the threshold with a black circle
      if metric < threshold
        % display the results
        metric_string = sprintf('%2.2f',metric);
        linearIdx = find(L == k);
        vertLineSegImg(linearIdx) = 1;
      end
    end

    imshow(vertLineSegImg);

    result = vertLineSegImg;