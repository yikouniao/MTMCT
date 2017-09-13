function traj = mergeResults(traj, labels, ids, in_group_ids)
u_labels = unique(labels);
for i = 1 : numel(u_labels)
    % cluster old ids
    cluster_id = unique(ids(labels == u_labels(i))); cluster_id(cluster_id==-1) = [];
    % either we face an already established trajectory or it's a new one!
    if isempty(cluster_id), ids_all = cellfun(@(x) x.MC_id, traj, 'uniformoutput', false); cluster_id = max([ids_all{:}]) + 1; end
    % apply new ids to the cluster
    for j = in_group_ids(labels == u_labels(i))', traj{j}.MC_id = cluster_id; end
end