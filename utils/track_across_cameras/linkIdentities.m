function traj = linkIdentities(traj, traj_f, startTime, endTime, opts)
sameIDvalue = 20;

w_f = [1 0.8 0.6 0.8 1];

% select trajectories that will be associated in this time window
% either because they fall in the time range or because they belong to
% identities who do so.
time_condition = traj_f(:, 2) > startTime & traj_f(:, 1) < endTime;
ids_win = cellfun(@(x) x.MC_id, traj(time_condition), 'uniformoutput', false); ids_win = unique([ids_win{:}]); ids_win = ids_win(ids_win~=-1);
ids_all = cellfun(@(x) x.MC_id, traj, 'uniformoutput', false); ids_all = [ids_all{:}]';
in_window = time_condition | ismember(ids_all, ids_win); in_window_ids = find(in_window);
this_traj = traj(in_window); ids = cellfun(@(x) x.MC_id, this_traj, 'uniformoutput', false); ids = [ids{:}]';

% APPEARANCE GROUPING
if numel(this_traj) < 1, return; end
app_grouping_labels = findAppearanceGroups(this_traj, ids, opts.group_size, w_f);

%% SOLVE SUBPROBLEMS
for l = unique(app_grouping_labels)'
    fprintf('\nSOLVING APPEARANCE GROUP %d of %d:\n', find(l==unique(app_grouping_labels)), numel(unique(app_grouping_labels))); fprintf('--------------------------------------------------------------------------\n');
    this_traj_app = this_traj(app_grouping_labels==l);
    in_group_ids  = in_window_ids(app_grouping_labels==l);
    
    %% COMPUTE EVIDENCE MATRICES
    [feasibilityMatrix, motionMatrix, globalAppearanceMatrix, indifferenceMatrix] = computeMatrices(this_traj_app,w_f);

    correlationMatrix = ...
        2 * globalAppearanceMatrix + ...
        1 * motionMatrix.*(1-indifferenceMatrix);
    
    correlationMatrix(correlationMatrix > 100) = Inf; correlationMatrix(correlationMatrix < -100) = -Inf;
    correlationMatrix(~feasibilityMatrix) = -Inf;
    correlationMatrix(isnan(correlationMatrix)) = 0;
    correlationMatrix(eye(size(correlationMatrix))==1) = 0;
    
    if opts.visualize == true
        figure(1);
        subplot(1, 4, 1); imagesc(globalAppearanceMatrix); colorbar; title('(A)ppearance')
        subplot(1, 4, 2); imagesc(motionMatrix); colorbar; title('(M)otion')
        subplot(1, 4, 3); imagesc(indifferenceMatrix); colorbar; title('(I)ndifference')
        subplot(1, 4, 4); imagesc(correlationMatrix); colorbar; title('Correlation = A + M * (1-I)')
        drawnow;
        pause
    end
    
    %%
    % IMPOSE HARD LINKS
    % check if trajectories involved in the correlation matrix already have a
    % link = add super positive evidence to those. I also do not want to merge
    % two trajectories that were previously tracked = add super negative
    % evidence to those.
    ids = cellfun(@(x) x.MC_id, this_traj_app, 'uniformoutput', false); ids = [ids{:}]';
    pos = find(ids~=-1); if numel(pos) > 1, combos = nchoosek(pos, 2); else combos = []; end
    for j = 1 : size(combos, 1)
        % either they are the same or they are different
        if ids(combos(j, 1)) == ids(combos(j, 2)), mul = +1; else mul = -1; end
        correlationMatrix(combos(j, 1), combos(j, 2)) = mul*sameIDvalue; correlationMatrix(combos(j, 2), combos(j, 1)) = mul*sameIDvalue;
    end
       
    % SOLVE BIP PROBLEM
    fprintf('Solving BIP subproblem...\n'); t_bip = tic;
    greedySolution = AL_ICM(sparse(correlationMatrix)); % init solution to BIP
    labels         = solveBIP(correlationMatrix, greedySolution);
    fprintf('\b done in %d sec!\n', round(toc(t_bip)));
    
    % merge results
    traj = mergeResults(traj, labels, ids, in_group_ids);
    
end
end