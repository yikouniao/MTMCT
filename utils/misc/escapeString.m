function escapedString = escapeString(str, escapes)
% function escapedString = escapeString(str)
%   escapes all special characters (e.g. \r\n, \t, etc.) in the string str
%   and returns a string containing the required escape sequences to
%   reproduce the string e.g. with sprintf(escapedString).
%
%   Helpful for debug purposes. Note that this function is not optimized
%   for speed (yet).
%
%   parameters:
%       str             The string that should be escaped
%       escapedString   String with all special characters replaced with their 
%                       escape sequences

    len = length(str);
    escapedString = '';
    
    if (nargin < 1)
        return;
    end
    
    %escapes = {'\r','\n','\t','\v','\\','''','\a','\b','%%','\0'};
    escaped = escapes;%{'\r','\n','\t','\v','\\','''','\a','\b','%%','\0'};
    
    elen = length(escapes);
    
    for (k=1:len)
        for (e=1:elen)
            found = false;
            if ( strcmp(str(k), sprintf(escapes{e})) )
                escapedString = [escapedString, escaped{e}];
                found = true;
                break;
            end
        end
        if (~found)
            escapedString = [escapedString, str(k)];
        end
    end
end