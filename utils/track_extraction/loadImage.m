function out = loadImage(varargin)
global dataset trajImages

% index global images variable or load images from disk
frame = varargin{1};
c     = varargin{2};

if nargin < 3
    out = trajImages{[trajImages{:, 1}]==frame, 2};
else
    out = imread(fullfile([dataset.framesDirectory(1:end-1) num2str(c)], sprintf(dataset.framesFormat, frame + syncTimeAcrossCameras(c))), 'jpg');
end



