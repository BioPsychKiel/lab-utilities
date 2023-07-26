% Data: EPOC (Walter Maetzler, University of Kiel)
% Author: Christian Neumann (Christian.Neumann@uksh.de)

%% define function
function oddball = oddball_beh(filename)
    %% Get data
    
    oddball     = table;
    c       = 1; % counter for long table
        
    % load data
    tmp = load_xdf(filename);

    markers = findLslStream(tmp,'PsychoPyMarker');

    % start with block 1
    idx_b1s = find(strcmp(markers.time_series,'block 1'));
    % Stimuli onset
    idx_ss = find(strcmp(markers.time_series,'Stimulus start'));
    % target stimulus onset
    idx_ts = find(strcmp(markers.time_series,'isi_time_1.5_trial_{''condition'': ''target''}'));
    % reactions
    idx_bps = find(strcmp(markers.time_series,'Space hit'));

    bps = 1; % counter for buttonpresses
    j = 6; % first target of Block 1
    for i = find(idx_ss == (idx_b1s+3)):numel(idx_ss) % loop starts with first stimulus of Block 1
        if idx_ss(i)-1 == idx_ts(j) % is this stimulus a target?
            if idx_ss(i)+2 == idx_bps(bps) % yes, the stimulus is a target! was the button pressed?
                oddball.accuracy(c)     = "hit";    % yes, button was pressed!
                oddball.rt(c)           = markers.time_stamps(idx_bps(bps)) - markers.time_stamps(idx_ss(i));
                c                   = c+1;      % next stimulus
                if j < length(idx_ts)
                    j                   = j+1;      % next target
                end
                if bps < length(idx_bps)
                    bps                 = bps+1;     % next buttonpress
                end
            else
                oddball.accuracy(c)     = "miss";    % no, button was not pressed!
                oddball.rt(c)           = nan;
                c                   = c+1;          % next stimulus
                if j < length(idx_ts)
                    j                   = j+1;           % next target
                end
            end
        else % no, the stimulus wasnt a target!
            if idx_ss(i)+2 == idx_bps(bps) % was the button pressed?
                oddball.accuracy(c)     = "false Alarm"; % yes, button was pressed!
                oddball.rt(c)           = nan;
                c                   = c+1;           % next stimulus
                if bps < length(idx_bps)
                    bps                 = bps+1;         % next buttonpress
                end
            else
                oddball.accuracy(c)     = "correct rejection";   % no, button was not pressed!
                oddball.rt(c)           = nan;
                c                   = c+1;
            end
        end
    end
end




