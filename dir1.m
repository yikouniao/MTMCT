function [dir] = dir1(thisModel, Mdl, path1, path2)
length = numel(thisModel);
%dir = zeros(length, 1);
dir = zeros(length, 1);
%{
path1 = 'D:/Documents/MTMCT/dataset/frames/';
path2 = 'E:/frames/';
%}
for i = 1:20:length
  m = thisModel{i};
  %det = valData(startPos(3)+i-1,:);
  % load images and generate HOG
  %feature_body = zeros(1,1440);
  if m.camera == 1 || m.camera == 2 || m.camera == 5
    fname = [path1, sprintf('camera%d/', m.camera), sprintf('%d.jpg', m.frame)];
  elseif m.camera == 9
    fname = [path2, sprintf('camera%d/', 8), sprintf('%d.jpg', m.frame)];
  else
    fname = [path2, sprintf('camera%d/', m.camera), sprintf('%d.jpg', m.frame)];
  end
  img = imread(fname);
  img = img(m.bb(1):m.bb(2), m.bb(3):m.bb(4), :);
  % resize all detections to w=87, h=223
  img = imresize(img, [223 87]);
  % set body to be 1/6 ~ 1
  img_body = img(37:223,:,:);
  % set head to be 0 ~ 1/5
  %img_head = img(1:45,:,:);
  %imshow(img);
  feature_body = extractHOGFeatures(img_body,'CellSize',[16 16],'BlockSize',[2 2]);
  label = 1; score = 0;
  % 
  [label1,score1] = predict(Mdl{1}.Mdl1,feature_body); if label1 == 1 && score1(2) > score label = 1; score = score1(2); end
  [label2,score2] = predict(Mdl{2}.Mdl2,feature_body); if label2 == 1 && score2(2) > score label = 2; score = score2(2); end
  [label3,score3] = predict(Mdl{3}.Mdl3,feature_body); if label3 == 1 && score3(2) > score label = 3; score = score3(2); end
  [label4,score4] = predict(Mdl{4}.Mdl4,feature_body); if label4 == 1 && score4(2) > score label = 4; score = score4(2); end
  [label5,score5] = predict(Mdl{5}.Mdl5,feature_body); if label5 == 1 && score5(2) > score label = 5; score = score5(2); end
  [label6,score6] = predict(Mdl{6}.Mdl6,feature_body); if label6 == 1 && score6(2) > score label = 6; score = score6(2); end
  [label7,score7] = predict(Mdl{7}.Mdl7,feature_body); if label7 == 1 && score7(2) > score label = 7; score = score7(2); end
  [label8,score8] = predict(Mdl{8}.Mdl8,feature_body); if label8 == 1 && score8(2) > score label = 8; end %score = score8(2);
  if i ~= 1
    diff = dirDiff(label, dir(i-1,1));
    if abs(diff) > 1
      if diff > 1
        dir(i,1) = dir(i-1,1) + 1;
      else
        dir(i,1) = dir(i-1,1) - 1;
      end
    else
      dir(i,1) = label;
    end
  else
    dir(i,1) = label;
  end
  
  for j = 1:19
    if i+j <= length
      dir(i+j,1)=dir(i,1);
    end
  end
  %{
  % what about 1 and 8 ???
  if i > 9
    dir(i) = round(mean(dir_(i-9:i)));
  else
    dir(i) = dir_(i);
  end
  %}
end
end