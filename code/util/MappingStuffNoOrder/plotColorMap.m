frech=newMeshList{5};
colorMap = frech.V;
colorMap(1,:) = (colorMap(1,:)-min(colorMap(1,:)))';
colorMap(2,:) = (colorMap(2,:)-min(colorMap(2,:)))';
colorMap(3,:) = (colorMap(3,:)-min(colorMap(3,:)))';
colorMap(1,:) = colorMap(1,:)/max(colorMap(1,:));
colorMap(2,:) = colorMap(2,:)/max(colorMap(2,:));
colorMap(3,:) = colorMap(3,:)/max(colorMap(3,:));

clear h
for i = 1:24
h(i) = subplot(3,8,i);
newMeshList{i}.draw(struct('FaceColor', 'interp', 'FaceVertexCData', colorMap', 'CDataMapping', 'scaled', 'EdgeColor', 'none', 'FaceAlpha', 1, 'AmbientStrength',0.7,'SpecularStrength',0.0));
%scatter3(newMeshList{i}.V(1,:),newMeshList{i}.V(2,:),newMeshList{i}.V(3,:),40,colorMap','MarkerFaceColor','flat',...
    %'MarkerFaceAlpha',.5);
axis off
hold on
end
Link = linkprop(h, {'CameraUpVector', 'CameraPosition', 'CameraTarget', 'CameraViewAngle'});
setappdata(gcf, 'StoreTheLink', Link);