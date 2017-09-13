config;
fprintf('Patience, this may take minutes (~400Mb)!\n');

mkdir(dataset.path);
fprintf('Downloading frames, foreground masks and single camera tracker output...\n');
url = sprintf('http://imagelab.ing.unimore.it/duke/MCT-Data.zip');
websave(fullfile(dataset.path, 'Data.zip'), url);
fprintf('Unzipping folder structure...\n');
unzip(fullfile(dataset.path, 'Data.zip'), dataset.path)
