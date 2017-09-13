function [bb, bb_pr] = getBB(data_id, f)
global dataset

frame_idx = data_id(:, 2) == f;

% get the patch
bb = round(data_id(frame_idx, [4 6 3 5]));
bb_pr = bb;
if isempty(bb), return; end

% compute fixed w/h ratio patch coordinates (useful if there is a training)
if false
    bb_box_actual_height = bb(2) - bb(1);
    bb_box_actual_height = bb_box_actual_height *1.10;
    bb_box_actual_width  = bb_box_actual_height /(98/40);
    bb_pr(1) = max(1, bb(1));
    bb_pr(2) = min(dataset.imageHeight, bb(1) + bb_box_actual_height);
    bb_pr(3) = max(1, (bb(3) + bb(4))/2-bb_box_actual_width/2);
    bb_pr(4) = min(dataset.imageWidth, (bb(3) + bb(4))/2+bb_box_actual_width/2);
    bb_pr    = round(bb_pr);
end

% remove this line to use original BB
bb = bb_pr;