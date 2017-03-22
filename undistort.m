%imlist = dir('../images/*.jpg');
imdir = '/playpen/colonpicture';
imlist = dir([imdir, '/images-artifact-removed/*.jpg']);
load([imdir, '/calibrationSession.mat']);

cameraParams = calibrationSession.CameraParameters;

for i = 1:length(imlist)
    fprintf('undistorted %d\n', i);
    I = imread([imdir, sprintf('/images-artifact-removed/%s',imlist(i).name)]);
    I = imresize(I,0.5);
    I = undistortImage(I,cameraParams);
    imwrite(I,[imdir, sprintf('/images-undistorted/frame%06d.jpg',i)]);
end


