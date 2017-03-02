% faraway pairs
path_to_images = '../group3/images/';
if(~exist('./farawaypairs', 'dir'))
    mkdir('./farawaypairs');
end
delete('./farawaypairs/*');
for i=1:count
    id1 = exhaustive_faraway_pairs(i, 1);
    id2 = exhaustive_faraway_pairs(i, 2);
    im1 = imread([path_to_images, imagesname_info{id1+1}]);
    im2 = imread([path_to_images, imagesname_info{id2+1}]);
    im = [im1, im2];
    imwrite(im, ['./farawaypairs/',num2str(id1),'_',num2str(id2),'_',num2str(exhaustive_faraway_pairs(i,3)),'.jpg'], 'jpg');
end