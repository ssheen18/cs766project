A = imread('test3_final.png');
[centers, radii] = imfindcircles(A, [1,2]);
hough_circles_draw('test3_final.png', centers, radii);
