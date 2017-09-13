function [out, traj_f] = loadAllTraj(opts)
global text dataset

%out = cell(1,6977); % hope it's proper(

% load Mdls
pathDirBody = 'D:/Documents/MTMCT/Direction-Model/classifier2-body/';
Mdl = cell(8,1);
for i = 1:8
    Mdl{i,1}=load([pathDirBody sprintf('Mdl%d.mat',i)]);
end

kk = 1;
for c = opts.cameras
    trackerOutput = double(load(fullfile(opts.path, 'SCT_output', sprintf('tracker_output_%d.txt', c))));
    idx = ismember(trackerOutput(:,2), dataset.frame_range(1):dataset.frame_range(2));
    trackerOutput = trackerOutput(idx==1, :);
    
    % discard bounding boxs whose bottom centers exceed 1920
    trackerOutput = trackerOutput(trackerOutput(:,5)<=1920,:);
    
    text = cell(1, 1); text{c} = ''; % initialize text streams    
    
    
    if c == 1 || c==2 || c==5
    vid = fullfile(opts.path, 'frames', sprintf('camera%d', c), opts.framesFormat);
    elseif c == 9
      vid = fullfile(opts.path2, 'frames', sprintf('camera%d', 8), opts.framesFormat);
    else
      vid = fullfile(opts.path2, 'frames', sprintf('camera%d', c), opts.framesFormat);
    end
    if c == 9
      msk = fullfile(opts.path, 'masks', sprintf('camera%d', 8), opts.masksFormat);
    else
    msk = fullfile(opts.path, 'masks', sprintf('camera%d', c), opts.masksFormat);
    end
    
        
    ids = unique(trackerOutput(:, 1));
    for idx = 1 : length(ids)
        printMyText(c, 'Computing tracks for traj %d of %d (cam %d)...\n', idx, length(ids), c);
        
        % extract features for current ID
        current_id = ids(idx);
        [data_id, frames]   = loadDataID(trackerOutput, current_id, c);
        
        thisModel = cell(1, length(frames));
        for f_idx = 1 : length(frames)
            f = frames(f_idx);
            
            % find img to world feet position in homogeneous coordinates
            [img_feet, wrl_feet, wrl_vel] = feetPosition(data_id, f, c);
            
            % explicit patch coords (bb_pr has fixed w/h ratio)
            bb = getBB(data_id, f);
            
            % store information about this frame
            current_id = data_id(1,1);
            thisModel{f_idx} = storeFrameInfo(c, current_id, f, img_feet, wrl_feet, wrl_vel, bb);
        end
        
        out{kk}.c = c; out{kk}.id = current_id; %#ok
        out{kk}.wrl_pos     = getPositionalInformation(thisModel); %#ok
        %[out{kk}.flag, out{kk}.appr] = getDirHSV1(thisModel, Mdl, [opts.path 'frames/'], [opts.path2 'frames/'], [opts.path 'masks/camera']);%#ok
        out{kk}.mean_hsv    = getBaselineDescriptor(thisModel, vid, msk); %#ok
        
        a                   = cellfun(@(x) x.bb, thisModel, 'uniformoutput', 0);
        out{kk}.bb          = cat(1, a{:}); %#ok
        kk = kk + 1;
    end
end

for i = 1 : numel(out), out{i}.MC_id = -1; end
traj_f = zeros(numel(out), 2);
for i = 1 : numel(out), if ~isempty(out{i}.wrl_pos), traj_f(i, :) = [out{i}.wrl_pos(1, 1) out{i}.wrl_pos(end, 1)]; end, end
