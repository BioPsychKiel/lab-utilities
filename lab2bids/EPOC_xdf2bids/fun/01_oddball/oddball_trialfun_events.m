
function [trl, event] = oddball_trialfun_events(cfg);

    % read the header information and the events from the data
    [data, events]  = xdf2fieldtrip(cfg.dataset);
    event           = struct2table(events);
    hdr             = data.hdr;

    % determine the number of samples before and after the trigger
    pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
    posttrig =  round(cfg.trialdef.post * hdr.Fs);

    sample          = sum(data.time{1,1} < event.timestamp(strcmp('Stimulus start',event.value)),2);
    trlbegin        = sample + pretrig;
    trlend          = sample + posttrig;

    % define the trials 
    trl             = [];
    trl(:,1)        = trlbegin;
    trl(:,2)        = trlend;
    trl(:,3)        = pretrig;

    c = 1;
    condition = [];
    for i = 1:length(event.value)
        if contains(event.value(i),'isi_time_1.5_trial_') 
            if strcmp(event.value(i),'isi_time_1.5_trial_{''condition'': ''standard''}')
                condition(c) = 0;
                c = c+1;
            elseif strcmp(event.value(i),'isi_time_1.5_trial_{''condition'': ''target''}')
                condition(c) = 1;
                c = c+1;
            else 
                condition(c) = 2;
                c = c+1;
            end
        end
    end
    condition       = condition';
    trl(:,4)        = condition(1:length(condition));

end
