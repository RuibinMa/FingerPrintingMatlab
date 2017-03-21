close all; clc;
%imdir = '/playpen/colonpicture';
imdir = '../colonpicture';
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

imshow(roi);
outcontour = roipoly;
incontour = roipoly;
incontour = ~incontour;
band = outcontour & incontour;
imshow(band);

%% test
testimg = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(9849).name])))));
roi = testimg(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1, :);
BW = edge(roi, 'canny');
BW = BW .* double(band);
imshow(BW);
[H,theta,rho] = hough(BW);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength',7);
figure, imshow(BW), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

%%
min_len_thres = 40;
parfor i = 1 : n
    xy_long = 0;
    I = mat2gray(double(rgb2gray(imread([imdir, '/images/', imlist(i).name]))));
    roi = I(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1, :);
    BW = edge(roi, 'canny');
    BW = BW .* double(band);
    %imshow(BW);
    [H,theta,rho] = hough(BW);
    P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength', min_len_thres - 1);
    %figure, imshow(BW), hold on
    max_len = 0;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        % Determine the endpoints of the longest line segment
        len = norm(lines(k).point1 - lines(k).point2);
        if ( len > max_len)
            max_len = len;
            xy_long = xy;
        end
    end
    % highlight the longest line segment
    score(i) = max_len;
    fprintf('%d\n', i);
end
scoremed = medfilt1(score);
figure;
ax = (1:1:n);
plot(ax, score);
hold on;
plot(ax, scoremed, 'r');
save('score.mat', 'score');
delete([imdir, '/images-artifact-removed/*']);
scorepos = find(scoremed <= min_len_thres);

ssd = zeros(n, 1);
incontourpos = find(~incontour > 0);
Iprev = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(1).name])))));
roiprev = Iprev(incontourpos);
for i=2:n
    Icurr = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(i).name])))));
    roicurr = Icurr(incontourpos);
    ssd(i) = sum((roicurr - roiprev).^2);
    if(ssd(i-1) < ssd(i))
        ssd(i-1) = ssd(i);
    end
    roiprev = roicurr;
    fprintf('%d\n', i);
end
ssd = ssd ./n;
save('ssd.mat', 'ssd');
figure;
plot(ax, ssd);

finalpos = find(score > 30 & ssd < 0.01);
find(score > 30);
    
parfor i=1:length(scorepos)
    img = imread([imdir, '/images/', imlist(scorepos(i)).name]);
    imwrite(img,[imdir, sprintf('/images-artifact-removed/%s',imlist(scorepos(i)).name)]);
    fprintf('%d\n', i);
end
    
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

