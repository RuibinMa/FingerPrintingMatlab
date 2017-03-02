% badly matched frames
badids = find(exhaustiveImages <= 5);
if(~exist('./badframes', 'dir'))
    mkdir('./badframes');
end
delete('./badframes/*');
path_to_images = '../group3/images/';
for i=1:length(badids)
    im = imread([path_to_images, imagesname_info{badids(i)}]);
    imwrite(im, ['./badframes/',num2str(badids(i)),'.jpg'], 'jpg');
end