function [dist] = distHSV(HSV1, HSV2)
%dist = sum(abs(HSV1-HSV2));
dist = norm(HSV1-HSV2,2);