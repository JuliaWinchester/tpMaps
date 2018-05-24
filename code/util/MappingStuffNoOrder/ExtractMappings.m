dataPath = 'E://Dropbox/clean_tali/';
namesPath = [dataPath 'Names.mat'];
meshesPath = [dataPath 'actual_aligned_meshes_5000/'];

load(namesPath);

numLmks = 500;
meshList = cell(length(Names),1);
GPLmkList = cell(length(Names),1);
GPPtClouds = cell(length(Names),1);
for i = 1:length(Names)
    load([meshesPath Names{i} '.mat']);
    meshList{i} = G;
    GPLmkList{i} = G.Aux.GPLmkInds;
    GPPtClouds{i} = G.V;
    %centralize point clouds
    GPPtClouds{i} = GPPtClouds{i} - repmat(mean(GPPtClouds{i}'),size(GPPtClouds{i},2),1)';
    GPPtClouds{i} = GPPtClouds{i}/norm(GPPtClouds{i});
end

procDists = zeros(length(Names),length(Names));
procMaps = cell(length(Names),length(Names));

for i = 1:length(Names)
    disp(i)
    for j = 1:length(Names)
        if i ~=j
            D = pdist2(GPPtClouds{i}',GPPtClouds{j}').^2;
            %[P,procDists(i,j),~] = linassign(ones(size(GPPtClouds{i},2),size(GPPtClouds{i},2)),D);
            %Get map from permutation
            curMap = zeros(size(GPPtClouds{i},2),1);
            for k = 1:length(curMap)
                dummy = find(D(k,:)==min(D(k,:)));
                curMap(k) = dummy(1); %break ties arbitrarily
            end
            procMaps{i,j} = curMap;
        end
    end
end



save('procMaps5000.mat','procMaps');
            
            