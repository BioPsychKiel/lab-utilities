%% define function
function nback = nback_beh(filename)
    %% get data

    nback   = table;
    c       = 1;

    % load data
    tmp = load_xdf(filename);
    markers = findLslStream(tmp,'PsychoPyMarker');

    % stimulus onset
    idx_ss = find(strcmp(markers.time_series,'Stimulus start'));
    % reactions
    idx_bps = find(strcmp(markers.time_series,'Space hit'));
    % target stimulus onset
    idx_ts = strfind(markers.time_series,'isi_time');
    t = 1;
    for i = 1:numel(idx_ts)
        if not(isempty(idx_ts{i}))
            idx_t(t) = i;
            t = t+1;
        end
    end
    idx_ts = [];
    t = 1;
    for i = 2:60
        if strcmp(string(markers.time_series(idx_t(i))),string(markers.time_series(idx_t(i-1))))
            idx_ts(t) = idx_t(i);
            t = t+1;
        end
    end

    for i = 63:numel(idx_t)
        if strcmp(string(markers.time_series(idx_t(i))),string(markers.time_series(idx_t(i-2))))
            idx_ts(t) = idx_t(i);
            t = t+1;
        end
    end


    bps = 1; % counter for buttonpresses
    j = 1;
    for i = 1:numel(idx_ss)
        if idx_ss(i)-2 == idx_ts(j)         % is this stimulus a target?
            if idx_ss(i)+1 == idx_bps(bps)  % yes, the stimulus is a target! was the button pressed?
                nback.accuracy(c)     = "hit";    % yes, button was pressed!
                nback.rt(c)           = markers.time_stamps(idx_bps(bps)) - markers.time_stamps(idx_ss(i));
                c                   = c+1;      % next stimulus
                if j < length(idx_ts)
                    j                   = j+1;      % next target
                end
                if bps < length(idx_bps)
                    bps                 = bps+1;     % next buttonpress
                end

                else
                nback.accuracy(c)     = "miss";    % no, button was not pressed!
                nback.rt(c)           = nan;
                c                   = c+1;          % next stimulus
                if j < length(idx_ts)
                    j                   = j+1;           % next target
                end
            end
        else % no, the stimulus wasnt a target!
            if idx_ss(i)+1 == idx_bps(bps) % was the button pressed?
                nback.accuracy(c)     = "false Alarm"; % yes, button was pressed!
                nback.rt(c)           = nan;
                c                   = c+1;           % next stimulus
                if bps < length(idx_bps)
                    bps                 = bps+1;         % next buttonpress
                end
            else
                nback.accuracy(c)     = "correct rejection";   % no, button was not pressed!
                nback.rt(c)           = nan;
                c                   = c+1;
            end
        end
    end
end



        
            

    




