clear all; close all; clc;
%% choice
%database_path = '/playpen/matchingResults/';
%database_path = '../matchingResults/';
%database_name = 'vocab262144_60_30';
%database_path = '../matchingResults/';
%database_name = 'vocab262144_100';
%database_path = '../colonpicture/';
%database_name = 'database-o-fov30';
database_path = '/playpen/colonpicture/';
%database_name = 'database-o-30-1-standard';
%database_name = 'database-m-30-1-standard';
database_name = 'database-o-30-1-m-15';
%% use the following system command to fetch data from database file
% the system command ">!", which means overwrite redirection, can be
% different across different systems. Some system uses ">" for overwrite.
if(~exist('./cache', 'dir'))
    mkdir('./cache');
end
delete('./cache/*');
if(~exist('./output', 'dir'))
    mkdir('./output');
end
system(['sqlite3 -csv -header ',database_path, database_name, '.db "SELECT rows FROM matches" > ./cache/result.csv']);
inlier_info = importdata(['./cache/result.csv']);
inlier = inlier_info.data;
system(['sqlite3 -csv -header ',database_path, database_name, '.db "SELECT pair_id FROM matches" > ./cache/pairid.csv']);
pairid_info = importdata(['./cache/pairid.csv']);
pairid = pairid_info.data;
system(['sqlite3 -csv -header ',database_path, database_name, '.db "SELECT image_id FROM images" > ./cache/images.csv']);
images_info = importdata(['./cache/images.csv']);
image_id = images_info.data;
system(['sqlite3 -csv -header ',database_path, database_name, '.db "SELECT name FROM images" > ./cache/image_names.csv']);
imagesname_info = importdata(['./cache/image_names.csv']);
imagesname_info = imagesname_info(2:end);
system(['sqlite3 -csv -header ',database_path, database_name, '.db "SELECT rows FROM keypoints" > ./cache/keypoints.csv']);
keypoints_info = importdata(['./cache/keypoints.csv']);
keypoints = keypoints_info.data;
%% read data from structures
Num_Images = length(image_id);
Num_Inlier = length(inlier);
% vocabulary tree matching
if(Num_Images > 3000)
    Matches = sparse(Num_Images, Num_Images);
else
    Matches = zeros(Num_Images);
end
NumOfMatchedImages = zeros(Num_Images, 1);


Inlier15Pairs = zeros(length(find(inlier == 15)), 4);
farid = 1;
for i=1:length(pairid)
    id2 = mod(pairid(i), 2147483647);
    id1 = floor((pairid(i) - id2)/2147483647 + 0.5);
    if(inlier(i) > 0.5)
        Matches(id1, id2) = inlier(i);%/(keypoints(id1) + keypoints(id2));
        NumOfMatchedImages(id1) = NumOfMatchedImages(id1) + 1;
        if(inlier(i) == 15)
            Inlier15Pairs(farid, :) = [id1, id2, 15, 0];
            farid = farid + 1;
        end
    end
end

ax = (1:1:Num_Images);
figure;
plot(ax, NumOfMatchedImages);
%figure('Name', 'Matches');
%mesh(Matches);
%mesh(Matches);

sample = randsample((1:1:size(Inlier15Pairs, 1)), 100);
sample = sort(sample);
Inlier15Pairs = Inlier15Pairs(sample, :);
IncorrectPairs = [];
figure;
for i=1:size(Inlier15Pairs)
    id1 = Inlier15Pairs(i, 1);
    id2 = Inlier15Pairs(i, 2);
    im1 = imread([database_path, 'images-good-standard/', imagesname_info{id1}]);
    im2 = imread([database_path, 'images-good-standard/', imagesname_info{id2}]);
    im1 = imresize(im1, 0.5);
    im2 = imresize(im2, 0.5);
    im = [im1, im2];
    imshow(im);
    title([num2str(id1),'-',num2str(id2),'-',num2str(Inlier15Pairs(i, 3))]);
    reply = input([num2str(i),': (',num2str(id1),', ',num2str(id2),') well-matched? y/n[default n]:'],'s');
    if isempty(reply)
        reply = 'n';
    end
    if(reply == 'n')
        IncorrectPairs = [IncorrectPairs; Inlier15Pairs(i, :)];
    end
end
save('IncorrectPairs.mat', 'IncorrectPairs');
for i=1:size(IncorrectPairs, 1)
    id1 = IncorrectPairs(i, 1);
    id2 = IncorrectPairs(i, 2);
    im1 = imread([database_path, 'images-good-standard/', imagesname_info{id1}]);
    im2 = imread([database_path, 'images-good-standard/', imagesname_info{id2}]);
    im1 = imresize(im1, 0.5);
    im2 = imresize(im2, 0.5);
    im = [im1, im2];
    imshow(im);
    title([num2str(id1),'-',num2str(id2),'-',num2str(Inlier15Pairs(i, 3))]);
    pause();
end
%% delete cache
delete('./cache/*');