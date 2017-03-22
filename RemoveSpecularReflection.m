close all; clc;
%% fix the specular reflections
%% test
imdir = '/playpen/colonpicture';
%imdir = '../colonpicture';
imlist = dir([imdir, '/images/*.jpg']);
n = length(imlist);
%% test (for some experiment)
testimg = imread([imdir, '/images/', imlist(5948).name]);
grayimg = mat2gray(double(rgb2gray(testimg)));
figure;
imshow(grayimg);
imhist(grayimg);
qf = quantile(reshape(grayimg, numel(grayimg), 1), 0.99);
pos = find(grayimg > qf);
result = grayimg;
result(pos) = 0;
imshow(result);

grayimg(pos) = NaN;
X = inpaint_nans(grayimg,2);
imshow(X);