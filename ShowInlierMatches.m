clear all; close all; clc;
% use the following system command to fetch data from database file
system('sqlite3 -csv -header ../group1withgarbage/database.db "SELECT rows FROM inlier_matches" > group1_result.csv');
inlier_info = importdata('./group1_result.csv');
inlier = inlier_info.data;
system('sqlite3 -csv -header ../group1withgarbage/database.db "SELECT image_id FROM images" > group1_images.csv');
images_info = importdata('./group1_images.csv');
image_id = images_info.data;
system('sqlite3 -csv -header ../group1withgarbage/database.db "SELECT rows FROM keypoints" > group1_keypoints.csv');
keypoints_info = importdata('./group1_keypoints.csv');
keypoints = keypoints_info.data;

% in the database.db from colmap, the inlier_matches is laid in the
% following pattern, where the x indicates the number is not contained in
% the 'rows' variable. The numbers show the order. 
%     x 1 2 3 4 5 6 7 8
%     x x 9101112131415 
%     x x x161718192021
%     x x x x2223242526
%     x x x x x27282930
%     x x x x x x313233
%     x x x x x x x3435
%     x x x x x x x x36
%     x x x x x x x x x

%% read data from structures
Num_Images = length(image_id);
Num_Inlier = length(inlier);
Matches = zeros(Num_Images);
id = 0;
for i=1:Num_Images
    for j= i+1:Num_Images
        id = id+1;
        Matches(i,j) = inlier(id)/(keypoints(i) + keypoints(j));
        Matches(j,i) = inlier(id)/(keypoints(i) + keypoints(j));
        
    end
end
figure;
mesh(Matches);