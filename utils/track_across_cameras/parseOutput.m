function output = parseOutput(traj, cameras)
global dataset
% initialize output
output = zeros(0, 7); trk_output = cell(1, max(cameras));

% preload data
for c = cameras
    trackerOutput = double(load(fullfile(dataset.path, 'SCT_output', sprintf('tracker_output_%d.txt', c))));
    trackerOutput(:, [7 8]) = trackerOutput(:, [7 8]) / 100;
    trk_output{c} = trackerOutput(:, [1 2 7 8 3 4 5 6]);
end

% assign unique identities to -1 cases
for i = 1 : numel(traj)
    if traj{i}.MC_id == -1
        traj{i}.MC_id = max(cellfun(@(x) x.MC_id, traj))+1;
    end
end

MC_ids = cellfun(@(x) x.MC_id, traj);
for i = unique(MC_ids)
    this_pos = find(MC_ids==i);
    for j = 1 : numel(this_pos)
        c = traj{this_pos(j)}.c;
        trk_data = trk_output{c}; % get camera data
        trk_data = trk_data(trk_data(:, 1) == traj{this_pos(j)}.id, :); % get only this id data
        trk_data(:, 1) = i;
        %output = [output; [c*ones(size(trk_data, 1), 1) trk_data(:, 2) i*ones(size(trk_data, 1), 1) trk_data(:, [9 10 11 12])]]; %#ok
        output = [output; [c*ones(size(trk_data, 1), 1) trk_data(:, 2) i*ones(size(trk_data, 1), 1) trk_data(:, 3:8)]]; %#ok
    end
end

% sort by camera, frame and id
output = sortrows(output, [1 2 3]);