function [data_id, frames] = loadDataID(trackerOutput, current_id, c)
data_id = trackerOutput(trackerOutput(:, 1) == current_id, :);
frames = data_id(:, 2);

% keep only frames where the person is moving at min_speed
m = 1; s = 1; speed_thresh = 0.10 * m/s;
wrl_vel = zeros(length(frames), 2);
wrl_pos = zeros(length(frames), 2);
% compute speed
for f_idx = 1 : length(frames)
    [~, wrl_pos(f_idx, :), wrl_vel(f_idx, :)] = feetPosition(data_id, frames(f_idx), c);
end

% suppress sparsiness and fill small gaps
good_vel_frames = find(sqrt(sum(wrl_vel.^2, 2)) > speed_thresh); selected_frames = zeros(numel(frames), 1);
if ~isempty(good_vel_frames)
    for f = 1 : numel(frames)
        frames_under_inspection = max(frames(good_vel_frames(1)), frames(f)-10):min(frames(good_vel_frames(end)), frames(f)+10);
        if sum(ismember(frames_under_inspection, frames(good_vel_frames))) > 10 && ...
                sqrt(sum((wrl_pos(min(numel(frames), f+20), :) - wrl_pos(max(1, f-20), :)).^2, 2)) > 1, selected_frames(f) = true; end
    end
    fill_selected = find(selected_frames);
    for i = 2 : numel(fill_selected)
        if fill_selected(i) - fill_selected(i-1) < 10, selected_frames(fill_selected(i-1):fill_selected(i)) = true; end
    end
end
frames = frames(selected_frames==1);
