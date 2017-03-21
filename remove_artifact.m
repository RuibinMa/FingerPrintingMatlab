close all; clc;
imdir = '/playpen/colonpicture';
%imdir = '../colonpicture';
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

band = outcontour & ~incontour;
imshow(band);

%% test
testimg = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(5000).name])))));
% roi = testimg(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1, :);
% BW = edge(roi, 'canny');
% BW = BW .* double(band);
% [H,theta,rho] = hough(BW);
% P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
% lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength',7);
% figure, imshow(roi), hold on
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end
% % highlight the longest line segment
% plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

%% use canny edge detection and hough transform to detect the artifact
min_len_thres = 60;
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
figure;
ax = (1:1:n);
plot(ax, score);
save('score.mat', 'score');

%% use the high scores as seed, to find their neighboring artifacts
scorepos = find(score > 70);
insidepos = find(incontour > 0);
%figure;
windowsize = 70;
R = cell(length(scorepos), 1);
label = zeros(n, 1);
for i=1:length(scorepos)
    label(scorepos(i)) = 1;
    I = mat2gray(double(rgb2gray(imread([imdir, '/images/', imlist(scorepos(i)).name]))));
    roi = I(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1);
    template = roi(insidepos);
    leftend = max(1, scorepos(i) - windowsize);
    rightend = min(n, scorepos(i) + windowsize);
    r = zeros(rightend - leftend + 1, 1);
    for j = leftend : rightend
        if(label(j)>0)
            continue;
        end
        Icand = mat2gray(double(rgb2gray(imread([imdir, '/images/', imlist(j).name]))));
        roicand = Icand(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1);
        candidate = roicand(insidepos);
        index = j - leftend + 1;
        r(index) = corr(template, candidate);
        if(r(index) > 0.95)
            label(j) = 1;
        end
    end
    R{i} = r;
    fprintf('%d/%d: %d expanded\n', i, length(scorepos), scorepos(i));
    %figure;
    %plot((leftend:rightend), r);
end
figure;
plot(ax, label);
frames_without_artifact = find(label == 0);
save('label.mat', 'label');
%%
% ssd = zeros(n, 1);
% incontourpos = find(incontour > 0);
% Iprev = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(1).name])))));
% roiprev = Iprev(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1);
% inprev = roiprev(incontourpos);
% for i=2:n
%     Icurr = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(i).name])))));
%     roicurr = Icurr(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1);
%     incurr = roicurr(incontourpos);
%     ssd(i) = sum((incurr - inprev).^2);
%     if(ssd(i-1) < ssd(i))
%         ssd(i-1) = ssd(i);
%     end
%     inprev = incurr;
%     fprintf('%d\n', i);
% end
% ssd = ssd ./n;
% save('ssd.mat', 'ssd');
% figure;
% plot(ax, ssd);

%% quantile function
% figure;
% imshow(roi);
% contour = roipoly;
% qfssd = zeros(n, 1);
% num_prob = 10;
% insidepos = find(contour > 0);
% outsidepos = find(~contour > 0);
% parfor i=1:n
%     I = mat2gray(double(rgb2gray((imread([imdir, '/images/', imlist(i).name])))));
%     roi = I(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1);
% 
%     inside = roi(insidepos);
%     outside = roi(outsidepos);
%     
%     qfinside = quantile(inside, num_prob);
%     qfoutside = quantile(outside, num_prob);
%     
%     qfssd(i) = sum((qfinside - qfoutside).^2) / num_prob;
% end
% save('qfssd.mat', 'qfssd');
% figure;
% plot(ax, qfssd);

%% select the images    
delete([imdir, '/images-artifact-removed/*']);
% parfor i=1:length(frames_without_artifact)
%     img = imread([imdir, '/images/', imlist(frames_without_artifact(i)).name]);
%     imwrite(img,[imdir, sprintf('/images-artifact-removed/%s',imlist(frames_without_artifact(i)).name)]);
%     fprintf('%d\n', i);
% end

%% inpaint the artifact areas
parfor i = 1:n
    I = double(imread([imdir, '/images/', imlist(i).name]));
    if(label(i) > 0)
        I(706:940,113:404,:)=NaN;
        X = I;
        X(:,:,1) = inpaint_nans(I(:,:,1),2);
        X(:,:,2) = inpaint_nans(I(:,:,2),2);
        X(:,:,3) = inpaint_nans(I(:,:,3),2);
        imwrite(uint8(X),[imdir, sprintf('/images-artifact-removed/%s',imlist(i).name)]);
    else
        I = double(imread([imdir, '/images/', imlist(i).name]));
    end
    fprintf('removed artifact from %d\n', i);
end

