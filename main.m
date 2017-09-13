clc; close all; clear
addpath(genpath('utils')); config; mydir = pwd;
cd('C:\gurobi702\win64\matlab'); gurobi_setup; cd(mydir);

% PARAMETERS
%dataset.frame_range = [56001 61000]; % ~5mins
%dataset.frame_range = [263504 356648]; % test-easy
%dataset.frame_range = [227541 263503]; % test-hard
dataset.frame_range = [127720 187540]; % train-mini
dataset.t_window    = 5000; % ~40secs
dataset.group_size  = 80;
dataset.visualize   = false; % internal relation matrices

computeFeatures     = true; % set to true to recompute features
tic;
%% LOAD SINGLE CAMERA TRAJECTORIES AND COMPUTE FEATURES 
if computeFeatures, [traj, traj_f] = loadAllTraj(dataset); save('traj.mat', 'traj', 'traj_f'); else load('traj.mat'); end %#ok

%% COMPUTE IDENTITIES
startTime = dataset.frame_range(1); endTime = dataset.frame_range(1) + dataset.t_window - 1;    % initialize range

while startTime <= dataset.frame_range(2)
    % print loop state
    clc; fprintf('Window %d...%d\n', startTime, endTime);
    
    % attach tracklets and store trajectories as they finish
    traj = linkIdentities(traj , traj_f, startTime, endTime, dataset);
    
    % update loop range
    startTime = endTime   - dataset.t_window/2;
    endTime   = startTime + dataset.t_window;
end
toc;
output = parseOutput(traj, dataset.cameras);
dlmwrite('final_output.txt', output, 'delimiter', ' ', 'precision', 6);

%% VISUALIZE RESULTS
%drawOnMap(traj);