function [out] = myGlobalAppearanceMatrix(flag1,appr1,flag2,appr2,w_f)
k1 = find(flag1'); k2 = find(flag2');
w = zeros(8,8);
out = 0;
for i = k1
  for j = k2
    w(i,j) = w_f(abs(dirDiff(i, j))+1);
    out = out + w(i,j) * sum(min([appr1(i,:); appr2(j,:)]));
  end
end

out = out / sum(w(:)) - 0.5;

end