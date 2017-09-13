%function [dist] = distHSV1(dAppr1, dAppr2, w_f)
function [dist] = distHSV1(flag1, appr1, flag2, appr2, w_f)

k1 = find(flag1'); k2 = find(flag2');
%n1 = size(k1,1); n2 = size(k2,1);
w = zeros(8,8);
dist = 0;

for i = k1
  for j = k2
    w(i,j) = w_f(abs(dirDiff(i, j))+1);
    dist = dist + w(i,j) * distHSV(appr1(i,:), appr2(j,:));
  end
end

dist = dist / sum(w(:));
end