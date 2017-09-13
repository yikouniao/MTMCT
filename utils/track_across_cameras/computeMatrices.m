function [feasibilityMatrix, motionMatrix, globalAppearanceMatrix, indifferenceMatrix] = computeMatrices(traj,w_f)
global text; text = cell(4, 1); % initialize text streams
N = length(traj);

% parameters
par_indifference = 9000;
speedLimit       = 2.0;
frameRate        = 60;

%% create binary feasibility matrix based on speed and direction
fprintf('Computing feasibility matrix: '); t = tic; text{1} = ''; c = 0;
feasibilityMatrix = zeros(N, N); N_t = N;
for i = 1 : N_t-1
    for j = i+1 : N_t
        c = c+1;
        printMyText(2, 'pair %d of %d (time elapsed: %d sec)\n', c, nchoosek(N, 2), round(toc(t)));
        
        if ~isempty(traj{i}.wrl_pos) && ~isempty(traj{j}.wrl_pos)
            % temporal ordering is required here
            if traj{i}.wrl_pos(1, 1) < traj{j}.wrl_pos(1, 1), A = traj{i}; B = traj{j}; else A = traj{j}; B = traj{i}; end
            % compute required number of frames
            distance    = sqrt(sum((A.wrl_pos(end, [2 3]) - B.wrl_pos(1, [2 3])).^2));
            frames_betw = abs(B.wrl_pos(1, 1) - A.wrl_pos(end, 1));
            min_number_of_required_frames = distance / speedLimit * frameRate;
            
            % compute directional information
            L1 = sqrt(sum((A.wrl_pos(end, [2 3]) - B.wrl_pos(  1, [2 3])).^2));
            L2 = sqrt(sum((A.wrl_pos(end, [2 3]) - B.wrl_pos(end, [2 3])).^2));
            L3 = sqrt(sum((A.wrl_pos(  1, [2 3]) - B.wrl_pos(  1, [2 3])).^2));
            
            if frames_betw > min_number_of_required_frames && L1 < L2 && L1 < L3 && ~isequal(A.c, B.c)
                feasibilityMatrix(i,j) = 1; % feasible association
            end
        end
    end
end
feasibilityMatrix = feasibilityMatrix + feasibilityMatrix';

%% motion information
fprintf('Computing motion matrix: '); t = tic; text{3} = ''; c = 0;
motionMatrix = zeros * ones(N, N); N_t = N;
for i = 1 : N_t-1
    for j = i+1 : N_t
        c = c+1;
        printMyText(3, 'pair %d of %d (time elapsed: %d sec)\n', c, nchoosek(N, 2), round(toc(t)));
        
        if ~isempty(traj{i}.wrl_pos) && ~isempty(traj{j}.wrl_pos) && feasibilityMatrix(i,j) == 1
            % temporal ordering is required here
            if traj{i}.wrl_pos(1, 1) < traj{j}.wrl_pos(1, 1), A = traj{i}; B = traj{j}; else A = traj{j}; B = traj{i}; end
            frame_difference = abs(B.wrl_pos(1, 1) - A.wrl_pos(end, 1)); % it could happen to be negative in overlapping camera settings
            space_difference = sqrt(sum((B.wrl_pos(1, [2 3]) - A.wrl_pos(end, [2 3])).^2, 2));
            needed_speed     = space_difference / frame_difference; %mpf
            speedA = sqrt(sum(diff(A.wrl_pos(:, [2 3])).^2, 2)); speedA = mean(speedA(max([2, end-9]):end));
            speedB = sqrt(sum(diff(B.wrl_pos(:, [2 3])).^2, 2)); speedB = mean(speedB(1:min([numel(speedB)-1, 10])));
            motionMatrix(i, j) = sigmf(min([abs(speedA-needed_speed), abs(speedB-needed_speed)]), [5 0])-0.53;
        end
    end
end
motionMatrix = motionMatrix + motionMatrix';

%% create global appearance matrix
fprintf('Computing global appearance similarities: ');
globalAppearanceMatrix = zeros(N, N); selectedMatrix = zeros(N, N); N_t = N;
parfor_progress(N_t);
for i = 1 : N_t-1
    parfor_progress;
    for j = 1 : N_t
        if j <= i, continue; end
        if feasibilityMatrix(i,j) > 0
          
            globalAppearanceMatrix(i, j) = sum(min([traj{i}.mean_hsv; traj{j}.mean_hsv]));
            globalAppearanceMatrix(i, j) = globalAppearanceMatrix(i, j) - 0.5;
          
          %globalAppearanceMatrix(i, j) = myGlobalAppearanceMatrix(traj{i}.flag,traj{i}.appr,traj{j}.flag,traj{j}.appr,w_f);
            selectedMatrix(i, j)   = 1;
        end
    end
end
parfor_progress(0);
selectedMatrix = selectedMatrix + selectedMatrix';
globalAppearanceMatrix = globalAppearanceMatrix + globalAppearanceMatrix';
globalAppearanceMatrix(~selectedMatrix) = -Inf;

%% indifference matrix
fprintf('Computing indifference matrix: '); t = tic; text{4} = ''; c = 0;
indifferenceMatrix = zeros(N, N); N_t = N;
frame_difference = zeros(N,N);
for i = 1 : N_t-1
    for j = i+1 : N_t
        c = c+1;
        printMyText(4, 'pair %d of %d (time elapsed: %d sec)\n', c, nchoosek(N, 2), round(toc(t)));
        if ~isempty(traj{i}.wrl_pos) && ~isempty(traj{j}.wrl_pos)
            % temporal ordering is required here
            if traj{i}.wrl_pos(1, 1) < traj{j}.wrl_pos(1, 1), A = traj{i}; B = traj{j}; else A = traj{j}; B = traj{i}; end
            frame_difference(i, j) = max(0, B.wrl_pos(1, 1) - A.wrl_pos(end, 1)); % it could happen to be negative in overlapping camera settings
            indifferenceMatrix(i,j) = sigmf(frame_difference(i,j), [0.001 par_indifference/2]);
        end
    end
end
indifferenceMatrix = indifferenceMatrix + indifferenceMatrix';
