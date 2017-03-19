function mosiac()
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
matches_left = d_left(1:2,matches(1,:));
matches_right = d_right(1:2,matches(2,:));
matches_left(3,:) = 1;
matches_right(3,:) = 1;

matchNumber = size(matches,2);

%%Ransac using vlfeat
for i = 1:100
    x = vl_colsubset(1:matchNumber,4);
    array = [];
    for j = x
        array = cat(1, array, kron(matches_left(:,j)', vl_hat(matches_right(:,j))));
    end
    [A,B,C] = svd(double(array));
    
    D{i} = reshape(C(:,9),3,3);
    matches_right_homography = D{i} * double(matches_left);
    da = matches_right_homography(1,:)./matches_right_homography(3,:) - double(matches_right(1,:))./double(matches_right(3,:));
    dc = matches_right_homography(2,:)./matches_right_homography(3,:) - double(matches_right(2,:))./double(matches_right(3,:));
    K{i} = (da.*da + dc.*dc) < 6*6; 
    homography_dist(i) = sum(K{i});
end

[homography_dist, best_matches] = max(homography_dist);
D = D{best_matches};
K = K{best_matches};

%panorama
newim = [1 size(im_right,2) size(im_right,2) 1;
         1 1                size(im_right,2) size(im_right,2);
         1 1                1                1];
newim_in = D\newim;
newim_in(1,:) = newim_in(1,:)./newim_in(3,:);
newim_in(2,:) = newim_in(2,:)./newim_in(3,:);
left_u = min([1 newim_in(1,:)]):max([size(im_left,2) newim_in(1,:)]);
left_v = min([1 newim_in(2,:)]):max([size(im_left,1) newim_in(2,:)]);
[new_left, new_right] = meshgrid(left_u, left_v);
im_left_new = vl_imwbackward(im2double(im_left),new_left,new_right);
new_dim = D(3,1) * new_left + D(3,2) * new_right + D(3,3);
new_new_left = (D(1,1) * new_left + D(1,2) * new_right + D(1,3))./new_dim;
new_new_right = (D(2,1) * new_left + D(2,2) * new_right + D(2,3))./new_dim;
im_right_new = vl_imwbackward(im2double(im_right),new_new_left,new_new_right);

pan = ~isnan(im_left_new) + ~isnan(im_right_new);
im_left_new(isnan(im_left_new)) = 0;
im_right_new(isnan(im_right_new)) = 0;
panorama = (im_left_new + im_right_new)./pan;

imshow(panorama)
