% Data: EPOC (Walter Maetzler, University of Kiel)
% Author: Christian Neumann (Christian.Neumann@uksh.de)

%% define function
function rte = rte_beh(filename)
    %% Get data
    
    rte     = table;
    c       = 1; % counter for long table
    
    % load data
    tmp = load_xdf(filename);
    markers = findLslStream(tmp,'PsychoPyMarker');

    % start with block 1
    idx_b1s = find(strcmp(markers.time_series,'block 1'));
    % stimulus onset
    idx_ss = find(strcmp(markers.time_series,'Stimulus start'));
    % reactions
    idx_bps = find(strcmp(markers.time_series,'Space hit'));

    i_ss  = find(idx_ss==(idx_b1s+4));
    i_bps = find(idx_bps > idx_b1s);
    i_bps = i_bps(1);

    for i = i_ss:numel(idx_ss)
        if (idx_ss(i)+2) ~= idx_bps(i_bps) 
            rte.rt(c)           = NaN;
            rte.accuracy(c)     = "miss";
            if isempty(strfind(char(markers.time_series(idx_ss(i)-1)),'AV'))
                rte.modality(c)     = string(extractBefore(extractAfter(markers.time_series(idx_ss(i)-1),cell2mat(strfind(markers.time_series(idx_ss(i)-1),'condition'))+12),2));
            else
                rte.modality(c)     = string(extractBefore(extractAfter(markers.time_series(idx_ss(i)-1),cell2mat(strfind(markers.time_series(idx_ss(i)-1),'condition'))+12),3));
            end
            c                   = c+1;
        else
            rte.rt(c)           = markers.time_stamps(idx_bps(i_bps))-markers.time_stamps(idx_ss(i));
            rte.accuracy(c)     = "correct";
            if isempty(strfind(char(markers.time_series(idx_ss(i)-1)),'AV'))
                rte.modality(c)     = string(extractBefore(extractAfter(markers.time_series(idx_ss(i)-1),cell2mat(strfind(markers.time_series(idx_ss(i)-1),'condition'))+12),2));
            else
                rte.modality(c)     = string(extractBefore(extractAfter(markers.time_series(idx_ss(i)-1),cell2mat(strfind(markers.time_series(idx_ss(i)-1),'condition'))+12),3));
            end            
            c                   = c+1;
            if i_bps < length(idx_bps)
                i_bps               = i_bps+1;
            end
        end
    end
end




