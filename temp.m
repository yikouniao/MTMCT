%final_output(:,6)=final_output(:,6)-final_output(:,4);
%final_output(:,7)=final_output(:,7)-final_output(:,5);

%{
for i = 1:1081424
  if final_output(i,1) == 9
    final_output(i,1) = 8;
  end
end
%}

%{
%dlmwrite('final_output.txt', final_output, 'delimiter', ' ', 'precision', 6);
%load('final_output.txt');
m=final_output(2222,:);
img=imread('d:\Documents\MTMCT\dataset\frames\camera1\227614.jpg');
%img=imread(sprintf('d:\Documents\MTMCT\dataset\frames\camera1\%d.jpg',m(3)));
img=img(m(5):m(5)+m(7),m(4):m(4)+m(6),:);
imshow(img);
%}

%{
w_f = [1 0.8 0.6 0.8 1];
a.flag = [1;1;1;1;1;1;1;1]; b.flag = [1;1;1;1;1;1;1;1];
a.appr = ones(8,48); a.appr = a.appr / 48; b.appr = zeros(8,48); b.appr = b.appr / 48;
out = myGlobalAppearanceMatrix(a.flag,a.appr,b.flag,b.appr,w_f);
%}

load('final_output.txt');
%final_output = final_output(:,[1 3 2 6 7 8 9 4 5]);
final_output = final_output(:,[1 3 2 6 7 8 9]);
final_output(:,6) = final_output(:,6) - final_output(:,4);
final_output(:,7) = final_output(:,7) - final_output(:,5);
%final_output(:, [8 9]) = final_output(:, [8 9]) * 100;
for i = 1:size(final_output,1)
  if final_output(i,1) == 9
    final_output(i,1) = 8;
  end
end
dlmwrite('final_output.txt', final_output, 'delimiter', ' ', 'precision', 6);