%% prepare dataset for judgement
%database_path = '../colonpicture/models/';
database_path = '/playpen/colonpicture/models/';
models = dir(database_path);
models = models(3:end);
listOfFrames = [];
checked = zeros(length(imagesname_info), 1);
for i=1:length(models)
    list = importdata([database_path, models(i).name, '/seq.txt']);
    for j=1:length(list)
        name = list(j);
        for k=1:length(imagesname_info)
            if(strcmp(imagesname_info(k), name) && checked(k)==0)
                listOfFrames = [listOfFrames, k];
                checked(k) = 1;
                break;
            end
        end
    end
end

listOfFrames = sort(listOfFrames);
RegisteredSelectedFarAwayPairs = zeros(size(FarAwayPairs));
pairid = 1;
for i=1:size(FarAwayPairs, 1)
    id1 = FarAwayPairs(i, 1);
    id2 = FarAwayPairs(i, 2);
    n = FarAwayPairs(i, 3);
    if(~isempty(find(listOfFrames == id1, 1)) && ~isempty(find(listOfFrames == id2, 1)))
        RegisteredSelectedFarAwayPairs(pairid, :) = [id1, id2, n, 0];
        pairid = pairid + 1;
    end
end
RegisteredSelectedFarAwayPairs = RegisteredSelectedFarAwayPairs(1:pairid-1, :);
SelectedFarAwayPairs1 = [];
for i=1:length(listOfFrames)
    id1 = listOfFrames(i);
    pos = find(RegisteredSelectedFarAwayPairs(:,1) == id1);
    id2s = RegisteredSelectedFarAwayPairs(pos,2);
    if(~isempty(id2s))
        [~, idx] = max(abs(id2s - id1*ones(size(id2s))));
        id2 = RegisteredSelectedFarAwayPairs(pos(idx), 2);
        SelectedFarAwayPairs1 = [SelectedFarAwayPairs1; [id1, id2, RegisteredSelectedFarAwayPairs(pos(idx), 3), 0]];
    end
end

UnRegisteredSelectedFarAwayPairs = zeros(size(FarAwayPairs));
pairid = 1;
for i=1:size(FarAwayPairs, 1)
    id1 = FarAwayPairs(i, 1);
    id2 = FarAwayPairs(i, 2);
    n = FarAwayPairs(i, 3);
    if(isempty(find(listOfFrames == id1, 1)) || isempty(find(listOfFrames == id2, 1)))
        UnRegisteredSelectedFarAwayPairs(pairid, :) = [id1, id2, n, 0];
        pairid = pairid + 1;
    end
end
SelectedFarAwayPairs2 = [];
UnRegisteredSelectedFarAwayPairs = UnRegisteredSelectedFarAwayPairs(1:pairid-1, :);
for i=1:Num_Images
    id1 = i;
    pos = find(UnRegisteredSelectedFarAwayPairs(:,1) == id1);
    id2s = UnRegisteredSelectedFarAwayPairs(pos,2);
    if(~isempty(id2s))
        [~, idx] = max(abs(id2s - id1*ones(size(id2s))));
        id2 = UnRegisteredSelectedFarAwayPairs(pos(idx), 2);
        SelectedFarAwayPairs2 = [SelectedFarAwayPairs2; [id1, id2, UnRegisteredSelectedFarAwayPairs(pos(idx), 3), 0]];
    end
end



x1 = randsample(length(SelectedFarAwayPairs1), 100);
x1 = sort(x1);
x2 = randsample(length(SelectedFarAwayPairs2), 100);
x2 = sort(x2);
SelectedFarAwayPairs = [SelectedFarAwayPairs1(x1, :); SelectedFarAwayPairs2(x2, :)];

save('SelectedFarAwayPairs.mat', 'SelectedFarAwayPairs');