function [trl] = trialfun_fulldata(cfg);

    % read the header information and the events from the data
    data  = xdf2fieldtrip(cfg.dataset);
    hdr             = data.hdr;

    % determine the number of samples before and after the trigger

    trlbegin        = 1; 
    trlend          = length(data.time{1});

    % define the trials 
    trl             = [];
    trl(:,1)        = trlbegin;
    trl(:,2)        = trlend;
    trl(:,3)        = 0;

end
