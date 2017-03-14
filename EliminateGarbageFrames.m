pos = find(NumOfMatchedImages > 200);
outputVideo = VideoWriter('goodframes.avi');
outputVideo.FrameRate = 21;
open(outputVideo);
for i = 1 : length(pos)
    
end