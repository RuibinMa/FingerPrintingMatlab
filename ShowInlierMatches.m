clear all; close all; clc;
%% use the following system command to fetch data from database file
% the system command ">!", which means overwrite redirection, can be
% different across different systems. Some system uses ">" for overwrite.
folder = 'group1';
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT rows FROM inlier_matches" >! ',folder,'_result.csv']);
inlier_info = importdata(['./',folder,'_result.csv']);
inlier = inlier_info.data;
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT pair_id FROM inlier_matches" >! ',folder,'_pairid.csv']);
pairid_info = importdata(['./',folder,'_pairid.csv']);
pairid = pairid_info.data;
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT image_id FROM images" >! ',folder,'_images.csv']);
images_info = importdata(['./',folder,'_images.csv']);
image_id = images_info.data;
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT rows FROM keypoints" >! ',folder,'_keypoints.csv']);
keypoints_info = importdata(['./',folder,'_keypoints.csv']);
keypoints = keypoints_info.data;
%% read data from structures
Num_Images = length(image_id);
Num_Inlier = length(inlier);
Matches = zeros(Num_Images);
for i=1:length(pairid)
    id2 = mod(pairid(i), 2147483647);
    id1 = round((pairid(i) - id2)/2147483647)+1;
    Matches(id1, id2) = 2*inlier(i)/(keypoints(id1) + keypoints(id2));
    Matches(id2, id1) = 2*inlier(i)/(keypoints(id1) + keypoints(id2));
end
figure('Name', 'Dice Coefficients');
imshow(mat2gray(Matches));