CS766 - Music Symbol Segmentation in OMR

Akshaya Kalyanaraman, Abbinaya Kalyanaraman, Stephen Sheen

This project is focused on the music symbol segmentation aspect of the OMR pipeline and we have detected note heads, note stems and note beams separately, after which we have merged them to form 1 single image.

We have used closing and hough circle techniques to detect the note heads, found the stem candidates using median filtering, and then applied roundedness to detect the note stems.

We have adapted the pseudo structural descriptor technique that uses Loci features to detect the note beams.

We have then evaluated and calculated the precision and recall of the images, which gives the results as below:
75% precision and 95% recall


