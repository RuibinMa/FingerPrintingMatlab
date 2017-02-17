clear; close all; clc;
ax = [5,10,15,20,25,30,40,50,60,70,80,90,100];
y=[8.8100,17.9000,25.8800,33.2800,39.7600,45.7900,55.7800,63.8000,70.5100,75.7400,79.7200,83.1000,85.4700];
figure;
plot(ax, y);
xlabel('num closest images');
ylabel('retrived ratio');