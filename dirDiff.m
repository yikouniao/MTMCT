function [diff] = dirDiff(dirNew, dirOdd)
switch dirNew-dirOdd
  case 0
    diff = 0;
  case 1
    diff = 1;
  case 2
    diff = 2;
  case 3
    diff = 3;
  case 4
    diff = 4;
  case 5
    diff = -3;
  case 6
    diff = -2;
  case 7
    diff = -1;
  case -1
    diff = -1;
  case -2
    diff = -2;
  case -3
    diff = -3;
  case -4
    diff = -4;
  case -5
    diff = 3;
  case -6
    diff = 2;
  case -7
    diff = 1;
  otherwise
    diff = 0;
end
end