base_dir = 'E://Dropbox/clean_tali/actual_aligned_off_5000/';
meshList = cell(24,1);
for i = 1:length(Names)
    meshList{i} = Mesh('off',[base_dir Names{i} '_aligned.off']);
    [meshList{i}.Aux.GPLmkInds,~] = meshList{i}.GetGPLmk(500);
end
save('meshList5000.mat','meshList');
for i = 1:length(Names)
    G = meshList{i};
    save(['./actual_aligned_meshes_5000/' Names{i} '.mat'],'G');
end

