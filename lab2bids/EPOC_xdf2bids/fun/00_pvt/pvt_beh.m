%% define function 
function pvt = pvt_beh(filename)
    %% get data
    tmp = load_xdf(filename);
    
    markers = findLslStream(tmp,'PsychoPyMarker');
    
    pvt     = table;
    c       = 1; % counter for long table
    
    % find all trial starts and button presses
    idx_ts = find(strcmp(markers.time_series,'Trial start'));
    idx_bps = find(strcmp(markers.time_series,'BP'));
    
    %prelocate
    
    for i = 9:numel(idx_bps)
        if idx_bps(i)-idx_ts(i) ~= 1; continue;end
        pvt.rt(c)   = markers.time_stamps(idx_bps(i))-markers.time_stamps(idx_ts(i));
        pvt.trialnumber(c)              = i;
        c                               = c+1;
    end
end