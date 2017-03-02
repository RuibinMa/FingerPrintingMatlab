delete('./cache/*');
system(['sqlite3 -csv -header ',database_path, exhaustivedb_name, '.db "SELECT rows FROM matches" > ./cache/raw.csv']);
exhaustiveraw_info = importdata(['./cache/raw.csv']);
exhaustiveraw = exhaustiveraw_info.data;
ExhaustiveRawMatches = zeros(Num_Images);
for i=1:length(exhaustiveraw)
    id2 = mod(exhaustivepairid(i), 2147483647);
    id1 = floor((exhaustivepairid(i) - id2)/2147483647 + 0.5);
    if(abs(id2 - id1) > 30)
        ExhaustiveRawMatches(id1, id2) = exhaustiveraw(i);%/(keypoints(id1) + keypoints(id2));
        ExhaustiveRawMatches(id2, id1) = exhaustiveraw(i);%/(keypoints(id1) + keypoints(id2));
    end
end

path_to_images = '../group3/images/';
if(~exist('../geometricallyexcluded', 'dir'))
    mkdir('../geometricallyexcluded');
end
delete('../geometricallyexcluded/*');
for i=1:Num_Images
    for j= i:Num_Images
        if(ExhaustiveRawMatches(i,j) > 0.5 && ExhaustiveMatches(i,j) <= 0.5)
            im1 = imread([path_to_images, imagesname_info{i+1}]);
            im2 = imread([path_to_images, imagesname_info{j+1}]);
            im = [im1, im2];
            imwrite(im, ['../geometricallyexcluded/',num2str(i),'_',num2str(j),'.jpg'], 'jpg');
            fprintf('%s\n', [num2str(i),'_',num2str(j)]);
        end
    end
end
