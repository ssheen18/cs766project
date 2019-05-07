CS766 - Music Symbol Segmentation in OMR 

Authors: Akshaya Kalyanaraman, Abbinaya Kalyanaraman, Stephen Sheen


This project is focused on the music symbol segmentation aspect of the OMR pipeline and we have detected note heads, note stems and note beams separately, after which we have merged them to form 1 single image.

We have used closing and hough circle techniques to detect the note heads and have used dilation and overlap with note heads to find note stems.

We have adapted the pseudo structural descriptor technique that uses Loci features to detect the note beams.

We have then evaluated and calculated the precision and recall of the images, which gives the average results as below:
75% precision and 95% recall


