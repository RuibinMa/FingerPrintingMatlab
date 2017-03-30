%% prepare dataset for judgement
database_path = '../colonpicture/models/';
%database_path = '/playpen/colonpicture/models/';
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
        disp(name);
    end
end

listOfFrames = sort(listOfFrames);
TempSelectedFarAwayPairs = zeros(size(FarAwayPairs));
pairid = 1;
for i=1:size(FarAwayPairs, 1)
    id1 = FarAwayPairs(i, 1);
    id2 = FarAwayPairs(i, 2);
    n = FarAwayPairs(i, 3);
    if(~isempty(find(listOfFrames == id1, 1)) && ~isempty(find(listOfFrames == id2, 1)))
        TempSelectedFarAwayPairs(pairid, :) = [id1, id2, n, 0];
        pairid = pairid + 1;
    end
end
TempSelectedFarAwayPairs = TempSelectedFarAwayPairs(1:pairid-1, :);
SelectedFarAwayPairs = [];
for i=1:length(listOfFrames)
    id1 = listOfFrames(i);
    pos = find(TempSelectedFarAwayPairs(:,1) == id1);
    id2s = TempSelectedFarAwayPairs(pos,2);
    if(~isempty(id2s))
        [~, idx] = max(abs(id2s - id1*ones(size(id2s))));
        id2 = TempSelectedFarAwayPairs(pos(idx), 2);
        SelectedFarAwayPairs = [SelectedFarAwayPairs; [id1, id2, TempSelectedFarAwayPairs(pos(idx), 3), 0]];
    end
end

x = randsample(length(SelectedFarAwayPairs), 100);
x = sort(x);
SelectedFarAwayPairs = SelectedFarAwayPairs(x, :);

save('SelectedFarAwayPairs.mat', 'SelectedFarAwayPairs');