function out = smoothHist(h, bins)
out = h; var = 0.1;

s = 0;
for b = 1 : numel(bins)
    out(s+2:s+bins(b))   = out(s+2:s+bins(b))   + var*h(s+1:s+bins(b)-1);  % sum from right to left
    out(s+1:s+bins(b)-1) = out(s+1:s+bins(b)-1) + var*h(s+2:s+bins(b));    % sum from left to right
    out(s+1) = out(s+1) + var*h(s+1); out(s+bins(b)) = out(s+bins(b)) + var*h(s+bins(b)); % adjust border bins
    s = bins(b);
end


end