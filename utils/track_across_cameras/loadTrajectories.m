function [traj, traj_f] = loadTrajectories(cameras, frame_range, traj_dir)
% load trajectories - like they were from the same time window

fileList	= dir(fullfile(traj_dir, '*.mat')); N = numel(fileList);
traj        = cell(N, 1);
traj_f      = zeros(N, 2);
valid       = zeros(N, 1);
for i = 1 : N
    % check if trajectory belongs to one of the specified cameras
    if ~ismember(str2double(fileList(i).name(1)), cameras), continue; end
    
    % check validity of track w.r.t. length and frame range
    traj{i} = load(fullfile(traj_dir, fileList(i).name));
    if size(traj{i}.wrl_pos, 1) > 1 && traj{i}.wrl_pos(end, 1) >= frame_range(1) && traj{i}.wrl_pos(1, 1) <= frame_range(2)
        valid(i) = 1; traj_f(i, :) = [traj{i}.wrl_pos(1, 1) traj{i}.wrl_pos(end, 1)];
    end
end

% filter output
traj   = traj(valid==1);
traj_f = traj_f(valid==1, :);
