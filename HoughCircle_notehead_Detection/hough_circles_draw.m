function img = hough_circles_draw(img, centers, radii)
    % Draw lines found in an image using Hough transform.
    %
    % img: Image on top of which to draw lines
    % centers: each row of centers represents the center point of a circle
    % radii: each row of radii represents the corresponding radius for the circle center
    %img2 = 0 * img;
    fh1 = figure();
    imshow(img);
    hold on;
    for i = 1 : size(centers, 1)
        r = radii(i);
        center_x = centers(i, 2);
        center_y = centers(i, 1);
        theta = linspace(0, 2 * pi, 360);
        xx = center_x + r * cos(theta);
        yy = center_y + r * sin(theta);
        plot(xx, yy,'g', 'LineWidth', 2);
    end

img = saveAnnotatedImg(fh1);
end   
function annotated_img = saveAnnotatedImg(fh)
figure(fh); % Shift the focus back to the figure fh

% The figure needs to be undocked
set(fh, 'WindowStyle', 'normal');

% The following two lines just to make the figure true size to the
% displayed image. The reason will become clear later.
img = getimage(fh);
truesize(fh, [size(img, 1), size(img, 2)]);

% getframe does a screen capture of the figure window, as a result, the
% displayed figure has to be in true size. 
frame = getframe(fh);
frame = getframe(fh);
pause(0.5); 
% Because getframe tries to perform a screen capture. it somehow 
% has some platform depend issues. we should calling
% getframe twice in a row and adding a pause afterwards make getframe work
% as expected. This is just a walkaround. 
annotated_img = frame.cdata;
end

