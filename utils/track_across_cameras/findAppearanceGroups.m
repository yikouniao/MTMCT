function app_grouping_labels = findAppearanceGroups(this_traj, ids, max_people, w_f)

pos = find(ids~=-1); if numel(pos) > 1, combos = nchoosek(pos, 2); else combos = []; end
for j = 1 : size(combos, 1)
    % if they belong to the same identity use same feature for clustering
    if ids(combos(j, 1)) == ids(combos(j, 2))
        this_traj{combos(j, 2)}.mean_hsv = this_traj{combos(j, 1)}.mean_hsv;
        %{
        for kkk = 1:8
          if this_traj{combos(j, 2)}.flag(kkk,1) == 0 && this_traj{combos(j, 1)}.flag(kkk,1) == 1
            this_traj{combos(j, 2)}.flag(kkk,1) = 1; this_traj{combos(j, 2)}.appr(kkk,:) = this_traj{combos(j, 1)}.appr(kkk,:);
          elseif this_traj{combos(j, 2)}.flag(kkk,1) == 1 && this_traj{combos(j, 1)}.flag(kkk,1) == 0
            this_traj{combos(j, 1)}.flag(kkk,1) = 1; this_traj{combos(j, 1)}.appr(kkk,:) = this_traj{combos(j, 2)}.appr(kkk,:);
          elseif this_traj{combos(j, 2)}.flag(kkk,1) == 1 && this_traj{combos(j, 1)}.flag(kkk,1) == 1
            this_traj{combos(j, 2)}.appr(kkk,:) = this_traj{combos(j, 1)}.appr(kkk,:);
          end
        end
        %}
    end
end
histFeature = cellfun(@(x) x.mean_hsv, this_traj, 'uniformoutput', false); histFeature = cat(1, histFeature{:});

n_cluster = max(1, round(numel(this_traj)/max_people)); % 100 is better?

while true
    app_grouping_labels = kmeans(histFeature, n_cluster, 'emptyaction', 'drop', 'Replicates', 5);
    %app_grouping_labels = mykmeans(this_traj, n_cluster, 5, w_f);
    this_labels = unique(app_grouping_labels); label_count = histc(app_grouping_labels, this_labels);
    if all(label_count < max_people), break; else n_cluster = n_cluster + 1; end
end

while any(label_count < max_people/2) && numel(label_count) > 1
    [~, I] = sort(label_count);
    if sum(app_grouping_labels==this_labels(I(1))+app_grouping_labels==this_labels(I(2))) < max_people
        app_grouping_labels(app_grouping_labels==this_labels(I(1))) = app_grouping_labels(find(app_grouping_labels==this_labels(I(2)), 1));
        this_labels = unique(app_grouping_labels); label_count = histc(app_grouping_labels, this_labels);
    else
        break;
    end
end
