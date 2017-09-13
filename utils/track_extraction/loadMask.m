function mask = loadMask(varargin)
global trackerdata trajMasks

frame = varargin{1};
c = varargin{2};

if nargin < 4
    mask = trajMasks{[trajMasks{:, 1}]==frame, 2};
    % cut out of the foreground people that stand between the camera and ID
    data = trackerdata(trackerdata(:, 2) == frame, [1 9 10 11 12]);
    mask = removePropleFromForeground2D(data, varargin{3}, mask);
else
    %mask = imread(sprintf('F:/dukeChapel/camera%d/background/%d.png', c, frame + syncTimeAcrossCameras(c)), 'png');
    mask = imread(sprintf('F:/NLPR_MCT_Dataset/NLPR_MCT_Dataset/video/Dataset1/mask%d/%06d.png', c, frame + syncTimeAcrossCameras(c)), 'png');
    mask = im2double(mask);
end