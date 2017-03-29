close all; clear all; clc;
%% display the far away pairs
progress = 1; % record the progress here
load('FarAwayPairs.mat');
FarAwayPairs(progress:end, 4) = FarAwayPairs(progress:end, 4)*0;

%path_to_images = '/playpen/colonpicture/images-good/';
path_to_images = './images-good/';
imagenames = dir([path_to_images, '*.jpg']);

figure;
i = progress;
while(i >=1 && i <= size(FarAwayPairs, 1))
    id1 = FarAwayPairs(i, 1);
    id2 = FarAwayPairs(i, 2);
    im1 = imread([path_to_images, imagenames(id1).name]);
    im2 = imread([path_to_images, imagenames(id2).name]);
    im1 = imresize(im1, 0.5);
    im2 = imresize(im2, 0.5);
    im = [im1, im2];
    imshow(im);
    title([num2str(id1),'-',num2str(id2),'-',num2str(FarAwayPairs(i, 3))]);
    
    reply = input([num2str(i),': (',num2str(id1),', ',num2str(id2),') well-matched? y/n/q(quit)/1-9(backward step) [default y]:'],'s');
    if isempty(reply)
        reply = 'y';
    end
    if(reply == 'y')
        FarAwayPairs(i, 4) = 1;
    end
    if(reply == 'q')
        fprintf('\n Terminated By User: current progress = %d\n', i);
        fprintf(' Please record the progress in the 3rd line\n\n');
        
        save('FarAwayPairs.mat', 'FarAwayPairs');
        break;
    end
    if ~isempty(str2num(reply))
        fprintf('\nbackward %d step\n\n', str2num(reply));
        i = i-str2num(reply);
        i = max(0, i);
        FarAwayPairs(i+1:end, 4) = FarAwayPairs(i+1:end, 4)*0;
    end
    i = i+1;
end

if(i > 1)
    fprintf(' %d/%d pairs has already been checked, well-matched ratio = %.4f\n\n', i-1, length(FarAwayPairs), sum(FarAwayPairs(1:i-1, 4))/(i-1));
end