base_path = 'E://Dropbox/clean_tali/';
mesh_path = [base_path 'actual_aligned_meshes_5000/'];
load([base_path 'Names.mat']);
load([base_path 'meshList5000.mat']);

for i = 1:length(Names)
    meshList{i}.Aux.UniformizationV = spherical_conformal_map(meshList{i}.V',meshList{i}.F')';
    Lambda = CORR_calculate_conformal_factors(meshList{i}.F',meshList{i}.V',meshList{i}.Aux.UniformizationV');
    meshList{i}.Aux.Conf = CORR_calculate_conformal_factors_verts(meshList{i}.F',Lambda);
end

extremaRadius = 10;

for i = 1:length(Names)
    meshList{i}.Aux.ConfMaxInds = meshList{i}.FindLocalMax(meshList{i}.Aux.Conf,extremaRadius,0);
end

clear h;
figure;
for i = 1:length(Names)
    h(i) = subplot(3,8,i);
    meshList{i}.draw; hold on;
    scatter3(meshList{i}.V(1,meshList{i}.Aux.ConfMaxInds),meshList{i}.V(2,meshList{i}.Aux.ConfMaxInds),...
        meshList{i}.V(3,meshList{i}.Aux.ConfMaxInds),100,'filled');
end
Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
setappdata(gcf, 'StoreTheLink', Link);

confMatchesPairs = cell(length(Names),1);
visMatchesPairs = cell(length(Names),1);
for i = 1:length(Names)
    confMatchesPairs{i} = [];
    visMatchesPairs{i} = [];
end
frechMean = 5;
maps_path = 'E://Dropbox/clean_tali/procMaps5000.mat';
load(maps_path);
for i = 1:length(Names)
    if i ~= frechMean
        pairMatches = [];
        map_12 = knnsearch(meshList{frechMean}.V(:,meshList{frechMean}.Aux.ConfMaxInds)',...
            meshList{i}.V(:,meshList{i}.Aux.ConfMaxInds)');
        map_21 = knnsearch(meshList{i}.V(:,meshList{i}.Aux.ConfMaxInds)',...
            meshList{frechMean}.V(:,meshList{frechMean}.Aux.ConfMaxInds)');
        for j = 1:length(map_12)
            if map_21(map_12(j)) == j
                proc12 = procMaps{i,frechMean};
                proc21 = procMaps{frechMean,i};
                lmk12 = proc12(meshList{i}.Aux.ConfMaxInds(j));
                lmk21 = proc21(meshList{frechMean}.Aux.ConfMaxInds(map_12(j)));
                [dist12,~,~] = graphshortestpath(meshList{frechMean}.A,lmk12,...
                    meshList{frechMean}.Aux.ConfMaxInds(map_12(j)));
                [dist21,~,~] = graphshortestpath(meshList{i}.A,lmk21,...
                    meshList{i}.Aux.ConfMaxInds(j));
                
                if dist12 < 15 && dist21 < 15
                    confMatchesPairs{i} = [confMatchesPairs{i};...
                        meshList{i}.Aux.ConfMaxInds(j) meshList{frechMean}.Aux.ConfMaxInds(map_12(j))];
                    visMatchesPairs{i} = [visMatchesPairs{i};j map_12(j)];
                end
            end
        end
    end
end

clear h;
figure;
c = colorcube(length(meshList{frechMean}.Aux.ConfMaxInds));

for i = 1:length(Names)
    h(i) = subplot(3,8,i);
    meshList{i}.draw; hold on;
    if i ~= frechMean
        scatter3(meshList{i}.V(1,meshList{i}.Aux.ConfMaxInds(visMatchesPairs{i}(:,1))),...
            meshList{i}.V(2,meshList{i}.Aux.ConfMaxInds(visMatchesPairs{i}(:,1))),...
            meshList{i}.V(3,meshList{i}.Aux.ConfMaxInds(visMatchesPairs{i}(:,1))),100,c(visMatchesPairs{i}(:,2),:),'filled');
    else
        scatter3(meshList{i}.V(1,meshList{i}.Aux.ConfMaxInds),meshList{i}.V(2,meshList{i}.Aux.ConfMaxInds),...
            meshList{i}.V(3,meshList{i}.Aux.ConfMaxInds),100,c,'filled');
    end
end
Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
setappdata(gcf, 'StoreTheLink', Link);

save('confMatchesPairs5000.mat','confMatchesPairs');

load([base_path 'matchesPairs5000.mat']);

clear h;
figure;
h = subplot(1,2,1);
meshList{17}.draw; hold on;
colors = colorcube(size(matchesPairs{17},1));
scatter3(meshList{17}.V(1,matchesPairs{17}(:,1)),meshList{17}.V(2,matchesPairs{17}(:,1)),...
    meshList{17}.V(3,matchesPairs{17}(:,1)),100,colors,'filled');
h = subplot(1,2,2);
meshList{frechMean}.draw; hold on;
scatter3(meshList{frechMean}.V(1,matchesPairs{17}(:,2)),meshList{frechMean}.V(2,matchesPairs{17}(:,2)),...
    meshList{frechMean}.V(3,matchesPairs{17}(:,2)),100,colors,'filled');
Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
setappdata(gcf, 'StoreTheLink', Link);