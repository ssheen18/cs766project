%% Load  image
clear all;
clc;

img_list = {'p001', 'p002', 'p003'};
for i = 1:length(img_list)
img = imread([img_list{i} '.png']);  % already grayscale

%% Find Circles (Use hough transform for circles)
[centers, radii] = find_circles(img, [3,10]);
img = hough_circles_draw(img, centers, radii);
imwrite(im2double(img), ['hough_circles_' img_list{i} '.png']);
end
