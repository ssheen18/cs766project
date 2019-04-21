% Script to remove braces in a staffless sheet music with only symbols
%
% author: sheen2@wisc.edu

% loading the image to process
img = imread('CVCMUSCIMA_SR\CvcMuscima-Distortions\interrupted\w-06\symbol\p012.png');
% img = imread('CVCMUSCIMA_SR\CvcMuscima-Distortions\thickness-ratio\w-11\symbol\p008.png');
figure; imshow(img);

staff_img = imread('CVCMUSCIMA_SR\CvcMuscima-Distortions\interrupted\w-06\gt\p012.png');
%staff_img = imread('CVCMUSCIMA_SR\CvcMuscima-Distortions\thickness-ratio\w-11\gt\p008.png');
% figure; imshow(staff_img);

staff_struct_element = strel('line', 50, 90);
dilated_staff_img = imdilate(staff_img, staff_struct_element);
% figure; imshow(dilated_staff_img);

% cropping the image to only the first tenth (horizontally) of the image
cropped_size = ceil(size(img, 2) * 0.1);
cropped_img = img(:, 1:cropped_size);
%figure; imshow(cropped_img);

% finding length of staff
horizontal_sum = sum(dilated_staff_img, 2);
% tmp = sort(horizontal_sum);

% smallest_nonzero_index = -1;
% for i = 1:size(tmp)
%     if tmp(i) == 0 && tmp(i+1) ~= 0
%         smallest_nonzero_index = i+1;
%         break;
%     end
% end

% using staff lines only to find staff length
%plot(horizontal_sum, 1:size(img,1));

% setting a lower bound to separate projectile profiles into clusters
%lower_bound = mode(tmp(smallest_nonzero_index:end));
lower_bound = 50;
horizontal_sum = horizontal_sum - lower_bound*2;

longest_staff_length = 0;
left_ptr = 0;
right_ptr = 0;
isStaff = 0;
for i = 1:size(horizontal_sum)
    right_ptr = i;
    if horizontal_sum(i) > 0
        if isStaff == 1
            if longest_staff_length < right_ptr - left_ptr
                longest_staff_length = right_ptr - left_ptr;
            end
        else
            left_ptr = i;
            isStaff = 1;
        end
    else 
        left_ptr = i;
        isStaff = 0;
    end
end

%plot(horizontal_sum, 1:size(img,1));

% finding connected components
CC = bwconncomp(cropped_img);

% finding candidates within list of connected components
candidate_CC = [];

for i = 1:size(CC.PixelIdxList, 2)
    min_pixel = size(img, 1) + 1;
    max_pixel = 0;
    
    [row_num_list, col_num_list] = ind2sub([size(cropped_img, 1), size(cropped_img, 2)], ...
                                    CC.PixelIdxList{1,i});
    for j = 1:size(row_num_list, 1)
        row_num = row_num_list(j);
        
        if row_num < min_pixel
            min_pixel = row_num;
        end
        
        if row_num > max_pixel
            max_pixel = row_num;
        end
    end
    
    if max_pixel - min_pixel > longest_staff_length*2
        candidate_CC = [candidate_CC; i];
    end
end

% checks to see if candidate connected component is a brace or not
for i = 1:size(candidate_CC, 1)
    % creates candidate image with one single connected component
    candidate_CC_img = cast(zeros(size(cropped_img, 1), size(cropped_img, 2)), 'logical');
    [row_num_list, col_num_list] = ind2sub([size(cropped_img, 1), size(cropped_img, 2)], ...
                                                CC.PixelIdxList{1,i});
                                
    for j = 1:size(row_num_list, 1)
        candidate_CC_img(row_num_list(j), col_num_list(j)) = 1;
    end
    
    % applying a median filter with vertical window of 15x1 to keep only
    % vertical line segments
    filtered_candidate_img = medfilt2(candidate_CC_img, [15, 1]);

    %figure; imshow(filtered_candidate_img);

    % dilating filtered image to reconnect line segments that might belong
    % to the same brace
    struct_element = strel('line', 50, 90);
    dilated_candidate_img = imdilate(filtered_candidate_img, struct_element);

    %figure; imshow(dilated_candidate_img);
    
    % finding skeletons of dilated line segments
    skeleton_candidate_img = bwmorph(dilated_candidate_img, 'skel', Inf);
    
    %figure; imshow(skeleton_candidate_img);

    % finding the longest connected component in skeleton image
    skeleton_CC = bwconncomp(skeleton_candidate_img);
    
    longest_skeleton_length = 0;
    longest_skeleton_index = 0;
    for k = 1:size(skeleton_CC.PixelIdxList, 2)
        min_pixel = size(skeleton_candidate_img, 1) + 1;
        max_pixel = 0;

        [skeleton_row_list, skeleton_col_list] = ...
            ind2sub([size(skeleton_candidate_img, 1), size(skeleton_candidate_img, 2)], ...
                                        skeleton_CC.PixelIdxList{1,k});
                                    
        for m = 1:size(skeleton_row_list, 1)
            row_num = skeleton_row_list(m);

            if row_num < min_pixel
                min_pixel = row_num;
            end

            if row_num > max_pixel
                max_pixel = row_num;
            end
        end

        if max_pixel - min_pixel > longest_skeleton_length
            longest_skeleton_length = max_pixel - min_pixel;
            longest_skeleton_index = k;
        end
    end
    
    % if longest skeleton has a length equal to twice the longest staff
    % length, approximate a vertical straight line segment. Use the
    % horizontally dilated line segment to remove the corresponding brace
    % in the original image.
    if longest_skeleton_length > longest_staff_length*2
        [rows, cols] = ind2sub([size(cropped_img, 1), size(cropped_img, 2)], ...
                             skeleton_CC.PixelIdxList{1,longest_skeleton_index});
        mean_col = ceil(mean(cols));
        min_row = min(rows);
        max_row = max(rows);
        
        approx_line_img = cast(zeros(size(cropped_img, 1), size(cropped_img, 2)), 'logical');
        
        for n = min_row:max_row
            approx_line_img(n, mean_col) = 1;
        end
        
        %figure; imshow(approx_line_img);
        
        struct_element = strel('line', 40, 180);
        dilated_line_img = imdilate(approx_line_img, struct_element);
        
        %figure; imshow(dilated_line_img);

        final_CC = bwconncomp(dilated_line_img);

        [final_rows, final_cols] = ind2sub([size(cropped_img, 1), size(cropped_img, 2)], ...
                                                final_CC.PixelIdxList{1,1});
        
        for r = 1:size(final_rows, 1)
            for c = 1:size(final_cols, 1)
                img(final_rows(r),final_cols(c)) = 0;
            end
        end
    end
end

figure; imshow(img);