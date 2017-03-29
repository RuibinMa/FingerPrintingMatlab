clear all; close all; clc;
%% prepare dataset for judgement
database_path = '/playpen/colonpicture/models/';
models = dir(database_path);
models = models(3:end);
for i=1:length(models)
    list{i} = importdata([database_path, models(i).name, '/seq.txt']);
end
