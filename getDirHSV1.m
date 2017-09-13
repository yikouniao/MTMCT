function [flag, appr] = getDirHSV1(thisModel, Mdl, path1, path2, pathmask)

n_f = 5;
bins_hsv = [16 4 4];
parts = [0 0.5 1];

%{
path1 = 'D:/Documents/MTMCT/dataset/frames/';
path2 = 'E:/frames/';
pathmask = 'D:/Documents/MTMCT/dataset/masks/camera';
%}

% flag, whether the dir is valid; appr, appearance of each dir.
flag = zeros(8,1); appr = zeros(8, sum(bins_hsv)*(numel(parts)-1));

% sanity check
if isempty(thisModel), return; end

dir = dir1(thisModel, Mdl, path1, path2);
dir_ = zeros(size(dir,1),8);
dirCnt = zeros(8,1);

% select subset of frames to average
select = zeros(8,n_f);

% compute bin centers
min_max_hsv = [0   1;    0   1;    0   1]; centers_hsv = cell(1, 3);
for i = 1 : 3, centers_hsv{i} = min_max_hsv(i, 1) + (min_max_hsv(i, 2)-min_max_hsv(i, 1))/bins_hsv(i)/2 : (min_max_hsv(i, 2)-min_max_hsv(i, 1))/bins_hsv(i) : min_max_hsv(i, 2); end

for i = 1:8
  dir_(:,i) = dir==i;
  dirCnt(i,1) = sum(dir_(:,i));
  if dirCnt(i,1) > 60 % more than 60 frames in this dir
    flag(i) = 1; % true
    %select(i,:) = randi([1 dirCnt(i,1)],1,n_f);
    select(i,:) = round(linspace(1,dirCnt(i,1),n_f));
    k = find(dir_(:,i));
    select(i,:) = k(select(i,:));% + thisModel{1,1}.frame - 1;
  else
    flag(i) = 0; % false
  end
end

if flag(1)==0 && flag(2)==0 && flag(3)==0 && flag(4)==0 && flag(5)==0 && flag(6)==0 && flag(7)==0 && flag(8)==0
  [~,I]=max(dirCnt);
  flag(I)=1;
  select(I,:) = round(linspace(1, numel(thisModel), n_f));
end

for k = 1:8
  %mean_hsv = zeros(1, sum(bins_hsv)*(numel(parts)-1));
  
  if flag(k) == 0
    continue;
  end
  
for i = select(k,:)
    
    %[~, j] = min(cellfun(@(x) abs(x.frame/10-(floor(thisModel{i}.frame/10)+1)), thisModel));
    m = thisModel{i};%thisModel{j};
       
    % load image and mask
  if m.camera == 1 || m.camera == 2 || m.camera == 5
    fname = [path1, sprintf('camera%d/', m.camera), sprintf('%d.jpg', m.frame)];
  elseif m.camera == 9
    fname = [path2, sprintf('camera%d/', 8), sprintf('%d.jpg', m.frame)];
  else
    fname = [path2, sprintf('camera%d/', m.camera), sprintf('%d.jpg', m.frame)];
  end
    img = imread(fname);
    if m.camera == 9
      msk = imread([pathmask, sprintf('%d/', 8), sprintf('%d.png', m.frame)]);
    else
    msk = imread([pathmask, sprintf('%d/', m.camera), sprintf('%d.png', m.frame)]);
    end
    
    %showDetections(fname, [m(1) m(3:7)]);
    
    %figure(1); imshow(img); rectangle('Position', [m.bb(3) m.bb(1) m.bb(4)-m.bb(3) m.bb(2)-m.bb(1)]); pause
    try
        img = img(m.bb(1):m.bb(2), m.bb(3):m.bb(4), :);
        % resize all detections to w=87, h=223
        img = imresize(img, [223 87]);
        msk = msk(m.bb(1):m.bb(2), m.bb(3):m.bb(4));
        msk = imresize(msk, [223 87]);
        g=msk<128; msk(g)=0; msk(~g)=255; 
        
        %figure(1); imshow(img); drawnow;        
        
        % get hsv and lab images
        hsv__ = rgb2hsv(img);
        
        % split BB in 3 parts
        for j = 1 : numel(parts)-1
            hsv_ = hsv__(round(1+parts(j)*size(hsv__, 1)) : round(parts(j+1)*size(hsv__, 1)), :, :);
            msk_ = msk  (round(1+parts(j)*size(msk, 1))   : round(parts(j+1)*size(msk, 1)), :);
            msk_ = im2double(msk_);
            
            % mask images
            h = hsv_(:,:,1); s = hsv_(:,:,2); v = hsv_(:,:,3);
            
            % from RGB to HSV
            hsv_hist = [hist(h(msk_==1), centers_hsv{1}) hist(s(msk_==1), centers_hsv{2}) hist(v(msk_==1), centers_hsv{3})];
            
            % smooth histograms
            hsv_hist = smoothHist(hsv_hist, bins_hsv);
            
            % add to the average histogram
            appr(k,1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) = ...
                appr(k,1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) + hsv_hist;
        end
    catch
    end
end

% normalization
for j = 1 : numel(parts)-1
    appr(k,1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) = ...
        appr(k,1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) ./ (eps+sum(appr(k,1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)))) / (numel(parts)-1);
end
%appr(k,:) = mean_hsv;
end
end