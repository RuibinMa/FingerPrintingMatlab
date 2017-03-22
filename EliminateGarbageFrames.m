%% must run ShowInlierMatches before this script
inverse = 0;
threshold = 1;
num_min_inliers = 30;
%image_dir = '../colonpicture/';
image_dir = '/playpen/colonpicture/';

if inverse
    pos = find(NumOfMatchedImages <= threshold);
    outputVideo = VideoWriter([image_dir, 'videos/badframes_',num2str(num_min_inliers),'_',num2str(threshold),'.avi']);
else
    pos = find(NumOfMatchedImages > threshold);
    outputVideo = VideoWriter([image_dir, 'videos/goodframes_',num2str(num_min_inliers),'_',num2str(threshold),'.avi']);
end
outputVideo.FrameRate = 30;
open(outputVideo);

if(~inverse)
    delete([image_dir, 'images-good/*']);
end
for i = 1 : length(pos)
    img = imread([image_dir, 'images-undistorted/',imagesname_info{pos(i)+1}]);
    writeVideo(outputVideo, img);
    if(~inverse)
        imwrite(img, [image_dir, sprintf('images-good/frame%06d.jpg',pos(i))]);
    end
end
close(outputVideo);