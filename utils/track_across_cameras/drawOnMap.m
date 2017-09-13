function drawOnMap(traj)
global dataset
labels = cellfun(@(x) x.MC_id, traj, 'uniformoutput', false); labels = [labels{:}]';

map = imread('map2.png');


% loop through each uniquely identified pedestrian
all_ids = unique(labels(labels~=-1));
for id = 1 : length(all_ids)    
    this_id = find(labels==all_ids(id));
    c = 0;
    figure(3), clf;
    figure(4); clf; imshow(map); hold on;
    
    done = 0;
    for i = this_id'
        c = c+1;
        figure(3);
        
        vid = fullfile(dataset.path, 'frames', sprintf('camera%d', traj{i}.c), dataset.framesFormat);
        gallery_image = imread(sprintf(escapeString(vid, {'\\'}), traj{i}.wrl_pos(1,1)+syncTimeAcrossCameras(traj{i}.c)));
        
        try
            gallery_image = gallery_image(traj{i}.bb(1, 1):traj{i}.bb(1, 2), traj{i}.bb(1, 3)-40:traj{i}.bb(1, 4)+40, :);
            subplot(1, numel(this_id), c);
            imshow(gallery_image);

            figure(4); hold on;
            mapped = world_to_map(traj{i}.wrl_pos(:, [2 3]));
            plot(mapped(:,1), mapped(:,2), 'r', 'LineWidth',5);
            hold on; scatter(mapped(end,1), mapped(end,2), 50, 'b', 'filled');
            
            done = 1;
        catch
            continue;
        end
        
    end
    
    if done == 1, pause; end
end