% Creates elliptical structuring element using given angle in rad.
% Note: Currently, image size, center, and radii are hardcoded. 
%
% author: sheen2@wisc.edu
function se = createEllipticalStructuringElement(rad)


    imageSizeX = 7;
    imageSizeY = 5;
    [columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

    centerX = 4;
    centerY = 3;
    radiusX = 4;
    radiusY = 2;
    ellipsePixels = ((columnsInImage - centerX)*cos(rad) + (rowsInImage - centerY)*sin(rad)).^2 ./ radiusY^2 ...
        + ((columnsInImage - centerX)*sin(rad) - (rowsInImage - centerY)*cos(rad)).^2 ./ radiusX^2 <= 1;
    
%     imshow(ellipsePixels);



    se = strel('arbitrary', ellipsePixels);
end