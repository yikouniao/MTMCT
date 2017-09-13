function wrl_pos = getPositionalInformation(thisModel)
wrl_pos = []; if isempty(thisModel), return; end
wrl_pos = cellfun(@(x) x.wrl_feet', thisModel, 'uniformoutput', false);
wrl_pos = [cellfun(@(x) x.frame, thisModel)' [wrl_pos{:}]'];