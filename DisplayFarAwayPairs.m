close all; clear all; clc;
%% display the far away pairs
load('progress.mat');
fprintf('\n Start: current progress = %d\n\n', progress);
load('SelectedFarAwayPairs.mat');
SelectedFarAwayPairs(progress:end, 4) = SelectedFarAwayPairs(progress:end, 4)*0;

path_to_images = '/playpen/colonpicture/images-good-standard/';
%path_to_images = './images-good-standard/';
%path_to_images = '../colonpicture/images-good-standard/';
imagenames = dir([path_to_images, '*.jpg']);

figure;
i = progress;
while(i >=1 && i <= size(SelectedFarAwayPairs, 1))
    id1 = SelectedFarAwayPairs(i, 1);
    id2 = SelectedFarAwayPairs(i, 2);
    im1 = imread([path_to_images, imagenames(id1).name]);
    im2 = imread([path_to_images, imagenames(id2).name]);
    im1 = imresize(im1, 0.5);
    im2 = imresize(im2, 0.5);
    im = [im1, im2];
    imshow(im);
    title([num2str(id1),'-',num2str(id2),'-',num2str(SelectedFarAwayPairs(i, 3))]);
    
    reply = input([num2str(i),': (',num2str(id1),', ',num2str(id2),') well-matched? y/n/q(quit)/1-9(backward step) [default y]:'],'s');
    if isempty(reply)
        reply = 'y';
    end
    if(reply == 'y')
        SelectedFarAwayPairs(i, 4) = 1;
    end
    if(reply == 'q')
        fprintf('\n Terminated By User: current progress = %d\n', i);
        
        save('SelectedFarAwayPairs.mat', 'SelectedFarAwayPairs');
        progress = i;
        save('progress.mat', 'progress');
        break;
    end
    if ~isempty(str2num(reply))
        fprintf('\nbackward %d step\n\n', str2num(reply));
        i = i-str2num(reply);
        i = max(0, i);
        SelectedFarAwayPairs(i+1:end, 4) = SelectedFarAwayPairs(i+1:end, 4)*0;
    end
    i = i+1;
end

if(i > 1)
    fprintf('\n %d/%d pairs has already been checked, well-matched ratio = %.4f\n\n', i-1, length(SelectedFarAwayPairs), sum(SelectedFarAwayPairs(1:i-1, 4))/(i-1));
end