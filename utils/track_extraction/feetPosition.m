function [img_feet, wrl_feet, wrl_vel] = feetPosition(data_id, f, c)

% current information
frame_idx = find(data_id(:, 2) == f, 1);
img_feet = [data_id(frame_idx, 6), data_id(frame_idx, 3)+1/2*(data_id(frame_idx, 5)-data_id(frame_idx, 3))];
img_feet = circshift(img_feet, [0 1]);
%wrl_feet = [0 0]; wrl_vel = [0 0];

wrl_feet = image_to_world(img_feet, c);

% previous frame information (use 5 frames to be more robust)
frame_idx = find(data_id(:, 2) == f - 5, 1);
img_feet_old = [data_id(frame_idx, 6), data_id(frame_idx, 3)+1/2*(data_id(frame_idx, 5)-data_id(frame_idx, 3))];
img_feet_old = circshift(img_feet_old, [0 1]);
wrl_feet_old = image_to_world(img_feet_old, c);

% compute velocity vectors
if isempty(wrl_feet_old)
    wrl_vel = [0 0];
else
    wrl_vel = wrl_feet - wrl_feet_old;
end