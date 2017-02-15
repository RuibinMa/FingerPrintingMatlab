clear all; close all; clc;
%% choice
folder = 'group3';
compareWithExhaustiveMatching = 1;
%% use the following system command to fetch data from database file
% the system command ">!", which means overwrite redirection, can be
% different across different systems. Some system uses ">" for overwrite.
if(~exist('./cache', 'dir'))
    mkdir('./cache');
end
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT rows FROM inlier_matches" > ./cache/',folder,'_result.csv']);
inlier_info = importdata(['./cache/',folder,'_result.csv']);
inlier = inlier_info.data;
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT pair_id FROM inlier_matches" > ./cache/',folder,'_pairid.csv']);
pairid_info = importdata(['./cache/',folder,'_pairid.csv']);
pairid = pairid_info.data;
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT image_id FROM images" > ./cache/',folder,'_images.csv']);
images_info = importdata(['./cache/',folder,'_images.csv']);
image_id = images_info.data;
system(['sqlite3 -csv -header ../',folder,'/database.db "SELECT rows FROM keypoints" > ./cache/',folder,'_keypoints.csv']);
keypoints_info = importdata(['./cache/',folder,'_keypoints.csv']);
keypoints = keypoints_info.data;
%% read data from structures
Num_Images = length(image_id);
Num_Inlier = length(inlier);
% vocabulary tree matching
Matches = zeros(Num_Images);
for i=1:length(pairid)
    id2 = mod(pairid(i), 2147483647);
    id1 = round((pairid(i) - id2)/2147483647)+1;
    Matches(id1, id2) = 2*inlier(i)/(keypoints(id1) + keypoints(id2));
    Matches(id2, id1) = 2*inlier(i)/(keypoints(id1) + keypoints(id2));
end
figure('Name', 'Dice Coefficients');
imshow(mat2gray(Matches));
%% compare VocabTree Matching with Exhaustive matching
if(compareWithExhaustiveMatching)
    system(['sqlite3 -csv -header ../',folder,'/exhaustivematching.db "SELECT rows FROM inlier_matches" >! ./cache/',folder,'_exhaustiveresult.csv']);
    exhaustiveinlier_info = importdata(['./cache/',folder,'_exhaustiveresult.csv']);
    exhaustiveinlier = exhaustiveinlier_info.data;
    system(['sqlite3 -csv -header ../',folder,'/exhaustivematching.db "SELECT pair_id FROM inlier_matches" >! ./cache/',folder,'_exhaustivepairid.csv']);
    exhaustivepairid_info = importdata(['./cache/',folder,'_exhaustivepairid.csv']);
    exhaustivepairid = exhaustivepairid_info.data;
    % exhaustive matching
    ExhaustiveMatches = zeros(Num_Images);
    for i=1:length(exhaustivepairid)
        id2 = mod(exhaustivepairid(i), 2147483647);
        id1 = round((exhaustivepairid(i) - id2)/2147483647)+1;
        ExhaustiveMatches(id1, id2) = 2*exhaustiveinlier(i)/(keypoints(id1) + keypoints(id2));
        ExhaustiveMatches(id2, id1) = 2*exhaustiveinlier(i)/(keypoints(id1) + keypoints(id2));
    end
    retriveRatio = sum(inlier) / sum(exhaustiveinlier);
    fprintf('Retrive Ratio = %.2f%%\n', retriveRatio*100);
end
%% delete cache
delete('./cache/*');