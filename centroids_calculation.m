% Calculate the centroids of the image
% author: akalyanaram2@wisc.edu

function [center radius img2] = centroids_calculation(img)

cc = bwconncomp(img); 
stats = regionprops(cc, 'Area','Centroid'); 
center = cat(1,stats.Centroid);
area = cat(1,stats.Area);
radius_square = area / 3.14;
radius = sqrt(radius_square); 
fh1 = figure();
imshow(img)
hold on
plot(center(:,1),center(:,2),'y.')
hold off
img2 = saveAnnotatedImg(fh1);
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


