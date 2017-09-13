function [label]=mykmeans(traj, n_cluster, re, w_f) 
  N = numel(traj);
  label = zeros(N,re);
  sumd_re = zeros(n_cluster, re);
  
  % calculate all distances between trajs
  all_dist = zeros(N,N);
  for i = 1:N
    for j = i+1 : N
      all_dist(i,j) = distHSV1(traj{i}.flag, traj{i}.appr, traj{j}.flag, traj{j}.appr, w_f);
    end
  end
  all_dist = all_dist + all_dist';
  
  for k = 1:re % do re times and choose one that has min sumd
    cen_new = randi([1,N],n_cluster,1);
    % loop mainbody
    while 1
      cen_old = cen_new;
      % calculate which centroid the trajs belong to
      for i = 1:N
        [~,I] = min(all_dist(i,cen_old));
        label(i,k) = cen_old(I);
      end
    
      % update centroids
      cnt = 1;
      for i = 1:n_cluster
        sumd = NaN(N,1);
        for j = 1:N
          if label(j,k) == cen_old(i,1)
            sumd(j,1) = sum(all_dist(j,label(:,k)==cen_old(i,1)));
          end
        end
        [sumd_re(cnt,k),cen_new(cnt,1)] = min(sumd);
        cnt = cnt + 1;
      end
    
      % break if centroids don't change
      if numel(find(cen_new==cen_old)) == n_cluster
        break;
      end
    end
  end
  
  % choose the model that has min sumd
  sumd_re_sum = zeros(1,re);
  for k = 1:re
    sumd_re_sum(1,k) = norm(sumd_re(:,k));
  end
  [~,min_k] = min(sumd_re_sum);
  label = label(:,min_k);
  
  % turn the cluster into 1, 2, 3...
  [~,~,ic] = unique(label);
  for i = 1:n_cluster
    label(ic==i) = i;
  end
end
