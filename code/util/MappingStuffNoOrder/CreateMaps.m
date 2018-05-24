
BasePath = 'E:\\Dropbox\clean_tali\';
NamesPath = [BasePath 'Names.mat'];
load(NamesPath);

%offFiles = dir([GenusPath '\SphereOFF\*.off']);
%landmarkFiles = dir([GenusPath '\sphere_landmarks\*.txt']);
flatteners = {};
flag = 0;

DataDir = 'E://Dropbox/TeethData/Tali5000/';
%mapList = cell(24,1);
for i = 1:24
    if i ~= 5
        curDir = [DataDir Names{i} '__To__' Names{5} '/'];
        flatteners = {};
        flag = 0;
        [V,T]=read_off([curDir Names{5} '.off']);
        inds=load([curDir Names{5} '.txt']);
        flattener1=Flattener(V,T,inds);
        flattener1.orderTS();
        leadFlattener=flattener1;
        flattener1.flatten_orbifold();
        %fix numerical errors if exist
        flattener1.fixFlipsNew();
            %add to the cell array of flatteners
        flatteners{end+1}=flattener1;

        [V,T]=read_off([curDir Names{i} '.off']);
        inds=load([curDir Names{i} '.txt']);
        flattener1=Flattener(V,T,inds);
        flattener1.uncut_cone_inds=flattener1.uncut_cone_inds(leadFlattener.reorder_cones);
        flattener1.flatten_orbifold();
        %fix numerical errors if exist
        flattener1.fixFlipsNew();
            %add to the cell array of flatteners
        flatteners{end+1}=flattener1;
        map=UncutSurfMap(flatteners);
        map.compute(1,2);
        map.compute(2,1);
        mapList{i} = map;
    end
end
barCoordsList = cell(24,1);
for i = 1:24
    if i ~=5
        barCoordsList{i} = mapList{i}.barCoords{2,1};
    end
end
load('meshList5000.mat');

curMeshes = meshList;
newMeshList = cell(24,1);
frechMean=5;
for i = 1:24
    if i ~=5
        curMeshVerts = curMeshes{i}.V';
        newMeshVerts = barCoordsList{i}*curMeshVerts;
        newMeshList{i} = Mesh('VF',newMeshVerts',meshList{frechMean}.F);
    else
        newMeshList{i} = meshList{i};
    end
end
save('newMeshes2.mat','newMeshList');
%save('barCoordsList.mat','barCoordsList');
%save('mapList.mat','mapList');
dists = zeros(24,24);
for i = 1:24
    for j = 1:24
        dists(i,j) = norm(newMeshList{i}.V - newMeshList{j}.V);
    end
end
[Y,~] = mdscale(dists,3);
scatter3(Y(eulemurInds,1),Y(eulemurInds,2),Y(eulemurInds,3),100,'filled',[1 0 0]);
        