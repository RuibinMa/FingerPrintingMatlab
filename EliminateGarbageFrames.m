inverse = 0;
threshold = 15;
image_dir = '../colonpicture/';

if inverse
    pos = find(NumOfMatchedImages <= threshold);
    outputVideo = VideoWriter([image_dir, 'badframes_',num2str(threshold),'.avi']);
else
    pos = find(NumOfMatchedImages > threshold);
    outputVideo = VideoWriter([image_dir, 'goodframes_',num2str(threshold),'.avi']);
end
outputVideo.FrameRate = 21;
open(outputVideo);

for i = 1 : length(pos)
    img = imread([image_dir, 'images-undistorted/',imagesname_info{pos(i)+1}]);
    writeVideo(outputVideo, img);
    if(~inverse)
        imwrite(img, [image_dir, sprintf('images-good/frame%06d.jpg',i)]);
    end
end
close(outputVideo);