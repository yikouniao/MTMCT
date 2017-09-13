function printMyText(varargin)
idx = varargin{1}; % index of text stream

% need to be global (or be returned in and out, but is used only here...)
global text;

% delete previous text
for q = 1 : length(text{idx}); fprintf('\b'); end

% compose new text
N = length(varargin);
cmd = 'text{idx} = sprintf(varargin{2}';
for i = 3 : N, cmd = sprintf('%s, varargin{%d}', cmd, i); end
cmd = [cmd ');'];
eval(cmd);

% print it
fprintf('%s', text{idx});

end