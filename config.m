global dataset;
dataset = [];

% Dependency configuration
gurobiPath      = 'C:\gurobi702\win64\matlab';
ffmpegPath      = 'C:\ffmpeg\bin\ffmpeg.exe';
dataset.path    = 'D:/Documents/MTMCT/dataset/'; % local directory to download the dataset
dataset.path2   = 'E:/';

% data set parameters (no need to change below this point)
dataset.cameras = [1 2 3 4 5 6 7 9];%[1 2 5];
dataset.framesFormat = '%d.jpg';
dataset.masksFormat = '%d.png';
dataset.imageWidth = 1920;
dataset.imageHeight = 1080;