clear all; close all; clc;
image_dir = '/playpen/colonpicture/images-good/';
a = dir([image_dir, '*.jpg']);
outputVideo = VideoWriter('~/Desktop/goodframes.avi');
outputVideo.FrameRate = 21;
open(outputVideo);

for i = 1 : length(a)
    img = imread([image_dir,a(i).name]);
    writeVideo(outputVideo, img);
end
close(outputVideo);