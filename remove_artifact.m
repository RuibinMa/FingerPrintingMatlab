close all; clc;
imdir = '/playpen/colonpicture';
imlist = dir([imdir, '/images/*.jpg']);
n = length(imlist);
ref = 83;
refimg = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(ref).name])))));
figure;
imshow(refimg);

hg = imrect;
pos = round(wait(hg));
roi = refimg(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1, :);

score = zeros(n, 1);
parfor i = 1:n
    I = mat2gray(double(rgb2gray(imread([imdir, '/images/', imlist(i).name]))));
    roi = I(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1, :);
    a = edge(roi, 'canny', 0.5);
    a(round(size(a,1)*0.1) : round(size(a,1)*0.9), round(size(a, 2)*0.1) : round(size(a, 2)*0.9)) = 0;
    score(i) = sum(sum(a));
    fprintf('%d\n', i);
end
figure;
ax = (1:1:n);
plot(ax, score);
% parfor i = 1:n
%     I = double(imread([imdir, '/images/', imlist(i).name]));
%     I(706:940,113:404,:)=NaN;
%     X = I;
%     X(:,:,1) = inpaint_nans(I(:,:,1),2);
%     X(:,:,2) = inpaint_nans(I(:,:,2),2);
%     X(:,:,3) = inpaint_nans(I(:,:,3),2);
%     imwrite(uint8(X),[imdir, sprintf('/images-artifact-removed/%s',imlist(i).name)]);
%     fprintf('removed artifact from %d\n', i);
% end

