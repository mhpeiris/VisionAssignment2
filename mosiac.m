im_left = imread('parliament-left.jpg');
im_right = imread('parliament-right.jpg');
im_left = im2single(im_left);
im_right = im2single(im_right);
im_left = rgb2gray(im_left);
im_right = rgb2gray(im_right);

[f_left, d_left] = vl_sift(im_left);
[f_right, d_right] = vl_sift(im_right);

d_left_new = im2double(d_left);
d_right_new = im2double(d_right);
d_right_new = imresize(d_right_new,[128,28683]);
dist = dist2(d_left_new,d_right_new);

[matches, scores] = vl_ubcmatch(d_left,d_right,430);
matches_left = matches(1,:);
matches_right = matches(2,:);