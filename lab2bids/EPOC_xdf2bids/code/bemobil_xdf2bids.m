function bemobil_xdf2bids(config, varargin)
% Wrapper for fieldtrip function "data2bids"
% specifically for converting multimodal .xdf files to BIDS
%
% Inputs :
%   config [struct, with required fields filename, bids_target_folder, subject, eeg.stream_keywords
%
%
%       config.filename               = 'P:\...SPOT_rotation\0_source-data\vp-1'\vp-1_control_body.xdf';  % required, string, full path to the xdf file 
%       config.bids_target_folder     = 'P:\...SPOT_rotation\1_BIDS-data';  % required, string, bids target folder to be created
%       config.subject                = 1;                                  % required, subject numerical ID
%       config.session                = 'VR';                               % optional, string, session name if there were multiple sessions 
%       config.run                    = 1;                                  % optional, integer, run index
%       config.task                   = 'rotation';                         % optional, string, task name, default value 'defaultTask'
%       config.acquisition_time       = [2021,9,30,18,14,0.00];             % optional ([YYYY,MM,DD,HH,MM,SS]
%       config.markerstreams          = {'markerstream 1', 'event stream 2'}  % optional, by default all streams with the types "event", "events", "marker", "markers" (not case sensitive) containing at least one entry are defined as markerstreams
%
%
% EEG parameters
%--------------------------------------------------------------------------
%
%       config.eeg.stream_name        = 'BrainVision';                      % required, string, a unique keyword in EEG stream to be searched for
%       config.eeg.chanloc            ='P:\...SPOT_rotation\0_raw-data\vp-1'\vp-1.elc'; % optional, string, full path to the channel location file
%       config.eeg.elec_struct        = elecStruct;                         % optional, alternative to config.eeg.chanloc. Output struct of ft_read_sens 
%       config.eeg.location_labels    = {'chan1', 'chan2', ...};            % optional, cell array of size nchan X 1, replace channel names in the location file   
%       config.eeg.channel_labels     = {'chan1', 'chan2', ...};            % optional, cell array of size nchan X 1, replace channel names in the xdf file
%
%--------------------------------------------------------------------------
% Optional Inputs :
%       Provide optional inputs as key value pairs.
%       Usage:
%       bemobil_xdf2bids(config, 'general_metadata', generalInfo);
%
%       general_metadata
%       participant_metadata
%       eeg_metadata
%       motion_metadata
%       physio_metadata
%
% Authors :
%       Sein Jeung (seinjeung@gmail.com) & Soeren Grothkopp (s.grothkopp@secure.mailbox.org)
%--------------------------------------------------------------------------

% add load_xdf to path
ft_defaults
[filepath,~,~] = fileparts(which('ft_defaults'));
addpath(fullfile(filepath, 'external', 'xdf'))

%%
%--------------------------------------------------------------------------
%                   Check import configuration
%--------------------------------------------------------------------------

% check which modalities are included
%--------------------------------------------------------------------------
importEEG           = isfield(config, 'eeg');                               % assume EEG is always in

if ~importEEG
    error('Importing scripts require the EEG stream to be there for event processing')
end

% check for mandatory fields
%--------------------------------------------------------------------------
config = checkfield(config, 'filename', 'required', '');
config = checkfield(config, 'bids_target_folder', 'required', '');
config = checkfield(config, 'subject', 'required', '');
config.eeg = checkfield(config.eeg, 'stream_name', 'required', '');         % for now, the EEG stream has to be there for smooth processing

% acquisition time
config = checkfield(config, 'acquisition_time', [1800,12,31,5,5,5.000], 'default time');         % for now, the EEG stream has to be there for smooth processing

% assign default values to optional fields
%--------------------------------------------------------------------------
config = checkfield(config, 'task', 'DefaultTask', 'DefaultTask');
config = checkfield(config, 'load_xdf_flags',{'Verbose',1},'{''Verbose'',1}');
config = checkfield(config, 'markerstreams',{},'all streams with the types "event", "events", "marker", "markers" (not case sensitive) containing at least one entry are defined as markerstreams');

% validate file name parts
%--------------------------------------------------------------------------
pat = {' ' '_'};

if contains(config.task, pat)
    error('Task label MUST NOT contain space or underscore. Please change task label.')
end

if isfield(config, 'session')
    if contains(config.session, pat)
        error('Session label MUST NOT contain space or underscore. Please change task label.')
    end
end


% EEG-related fields
%--------------------------------------------------------------------------
if importEEG
    config.eeg = checkfield(config.eeg, 'stream_name', 'required', '');
end

%%
%--------------------------------------------------------------------------
%                           Check metadata
%--------------------------------------------------------------------------
% find optional input arguments
for iVI = 1:2:numel(varargin)
    if strcmp(varargin{iVI}, 'general_metadata')
        generalInfo         = varargin{iVI+1};
    elseif strcmp(varargin{iVI}, 'participant_metadata')
        subjectInfo         = varargin{iVI+1};
    elseif strcmp(varargin{iVI}, 'eeg_metadata')
        eegInfo             = varargin{iVI+1};
    else
        warning('One of the optional inputs are not valid : please see help bemobil_xdf2bids')
    end
end

% check general metadata
%--------------------------------------------------------------------------
if ~exist('generalInfo', 'var')
    
    warning('Optional input general_metadata was not entered - using default general metadata (NOT recommended for data sharing)')
    
    generalInfo = [];
    
    % root directory (where you want your bids data to be saved)
    generalInfo.bidsroot                                = config.bids_target_folder;
    
    % required for dataset_description.json
    generalInfo.dataset_description.Name                = 'EPOC';
    generalInfo.dataset_description.BIDSVersion         = 'unofficial extension';
    
    % optional for dataset_description.json
    generalInfo.dataset_description.License             = 'n/a';
    generalInfo.dataset_description.Authors             = '["Christian Neumann", "Johanna Geritz", "Julian Keil", "Walter Maetzler", "Julius Welzel"]';
    generalInfo.dataset_description.Acknowledgements    = 'n/a';
    generalInfo.dataset_description.Funding             = '["COVIDOM and Neurogeriatrics"]';
    generalInfo.dataset_description.ReferencesAndLinks  = 'n/a';
    generalInfo.dataset_description.DatasetDOI          = 'n/a';
    
    % general information shared across modality specific json files
    generalInfo.InstitutionName                         = 'University Hospital Schleswig-Holstein, Kiel Campus';
    generalInfo.InstitutionalDepartmentName             = 'Department of Neurology';
    generalInfo.InstitutionAddress                      = 'Arnold-Heller Straße 3, 24105 kiel, Germany';
    
    if string(config.task) == "oddball"
            generalInfo.TaskDescription                         = 'Subjects hear 3 different noises. One noise is a target, one is a distractor and one is a standard stimulus. Subjects only need to react to the target stimulus by pressing the spacebar.';
    elseif string(config.task) == "rte"
            generalInfo.TaskDescription                         = 'Subjects either see a white flashing circle on the display, a sound on the headphones that they are wearing or both at the same time. The moment that either of those stimuli appear, the subject is supposed to press the spacebar as fast as possible';
    elseif string(config.task) == "pvt"
            generalInfo.TaskDescription                         = 'Subjects are supposed to press the spacebar as fast as possible as soon as a counter starts. When the spacebar was pressed, the counter is stopped and shows the reaction time in miliseconds';
    elseif string(config.task) == "nback"
            generalInfo.TaskDescription                         = 'The display shows a series of letters. In the first part of the task, subjects are supposed to press the spacebar everytime the current letter is the same as the last letter. In the second part of the task subjects are supposed to press the spacebar everytime the current letter is the same as the letter that was shown to letters ago';
    end

    
end

cfg = generalInfo;

%%
% check if numerical IDs match subject info, if this was specified
%--------------------------------------------------------------------------
if exist('subjectInfo','var') && ~isempty(subjectInfo)
    
    nrColInd                = find(strcmp(subjectInfo.cols, 'nr'));
    
    % attempt to find matching rows in subject info
    pRowInd          = find(cell2mat(subjectInfo.data(:,nrColInd)) == config.subject,1);
    if isempty(pRowInd)
        warning(['Participant info not given : filling with n/a'])
        emptyRow         = {config.subject};
        [emptyRow{2:size(subjectInfo.data,2)}] = deal('n/a');
        newPInfo   = emptyRow;
    else
        newPInfo   = subjectInfo.data(pRowInd,:);
    end
    
else
    warning('Optional input participant_metadata was not entered - participant.tsv will be omitted (NOT recommended for data sharing)')
end

% construct file and participant- and file- specific config
% information needed to construct file paths and names
%--------------------------------------------------------------------------
cfg.sub                                     = num2str(config.subject,'%02.f');
cfg.dataset                                 = config.filename;
cfg.bidsroot                                = config.bids_target_folder;
cfg.participants                            = [];

if isfield(config, 'session')
    cfg.ses                                     = config.session;
end
if isfield(config, 'run')
    cfg.run                                     = config.run;
end
if isfield(config, 'task')
    cfg.task                                    = config.task;
else
    cfg.task                                    = 'defaultTask';
end

% participant information
if exist('subjectInfo', 'var') && ~isempty(subjectInfo)
    
    allColumns      = subjectInfo.cols;
    
    % find the index of the subject nr column
    for iCol = 1:numel(allColumns)
        if strcmp(subjectInfo.cols(iCol), 'nr')
            nrColInd = iCol;
        end
    end
    
    if ~exist('nrColInd','var')
        error('Participant info was provided without column "nr".')
    end
    
    % find the column that contains information from the given participant
    Pi = find([subjectInfo.data{:,nrColInd}] == config.subject); % find the matching participant number
    
    for iCol = 1:numel(allColumns)
        cfg.participants.(allColumns{iCol}) = subjectInfo.data{Pi, iCol};
    end
    
end

%%
% load and assign streams (parts taken from xdf2fieldtrip)
%--------------------------------------------------------------------------
disp('Loading .xdf streams ...')
streams                  = load_xdf(cfg.dataset,config.load_xdf_flags{:});

% initialize an array of booleans indicating whether the streams are continuous
ismarker = false(size(streams));
emptystream = false(size(streams));

names = {};

% figure out which streams contain continuous/regular and discrete/irregular data
for i=1:numel(streams)
    
    names{i}           = streams{i}.info.name;
    
    num_samples  = numel(streams{i}.time_stamps);
    
    emptystream(i) = num_samples == 0;
    
    if (~isfield(streams{i}.info, 'effective_srate') || isempty(streams{i}.info.effective_srate)) && num_samples > 1
        % in case effective srate field value is missing, add it, needs 2 samples to compute effective srate
        
        t_begin      = streams{i}.time_stamps(1);
        t_end        = streams{i}.time_stamps(end);
        duration     = t_end - t_begin;
        
        streams{i}.info.effective_srate = (num_samples - 1) / duration;
    end
    
    % at least one event must be present for the stream to be considered an event stream
    ismarker(i) =  contains(streams{i}.info.type,{'marker','markers','event','events'},'IgnoreCase',true) && num_samples > 0;
    
end

xdfeeg = {};
if importEEG
    eegStreamName = config.eeg.stream_name;
    xdfeeg        = streams(contains(lower(names),lower(eegStreamName)) & ~ismarker & ~emptystream);
    
    for i_thisstream = 1:length(xdfeeg)
        disp(['Found EEG stream: ' xdfeeg{i_thisstream}.info.name])
    end
    
    if isempty(xdfeeg)
        
        lower(names)
        lower(eegStreamName)
        error('No EEG streams found - check whether stream_name match the names of streams in .xdf')
        
    elseif numel(xdfeeg) > 1 && (~isfield(config,'eeg_index') || isempty(config.eeg_index))
        
        warning('Multiple eeg streams found - displaying them for inspection')
        
        for i=1:length(xdfeeg)
            xdfeeg{i}.info
        end
        
        warning('You can add a field "eeg_index" to the config and work around this issue by choosing only one EEG file.')
        error('Multiple EEG streams found - usage not supported!')
        
    elseif numel(xdfeeg) > 1 && isfield(config,'eeg_index') && ~isempty(config.eeg_index)
        
        warning('Multiple EEG streams found - choosing only the specified one to import!')
        xdfeeg = xdfeeg(config.eeg_index);
        
    end
end

if ~isempty(config.markerstreams)
    disp('Using defined marker streams:')
    xdfmarkers   = streams(contains(lower(names),config.markerstreams,'IgnoreCase',true));
else
    disp('Using default marker streams according to stream type:')
    xdfmarkers  = streams(ismarker);
end

for i_thisstream = 1:length(xdfmarkers)
    disp(['Found EVENT MARKER stream: ' xdfmarkers{i_thisstream}.info.name])
end

% %% plot raw data
% 
% if ~isempty(xdfmarkers) > 0
%     times_stamp_1 = inf;
%     times_stamp_2 = 0;
%     
%     event_1 = '';
%     event_2 = '';
%     
%     for i_markerstream = 1:length(xdfmarkers)
%         
%         if xdfmarkers{i_markerstream}.time_stamps(1) < times_stamp_1
%             times_stamp_1 = xdfmarkers{i_markerstream}.time_stamps(find(xdfmarkers{i_markerstream}.time_stamps > xdfeeg{1}.time_stamps(1),1,'first'));
%             event_1 = xdfmarkers{i_markerstream}.time_series(find(xdfmarkers{i_markerstream}.time_stamps > xdfeeg{1}.time_stamps(1),1,'first'));
%         end
%         if xdfmarkers{i_markerstream}.time_stamps(end) > times_stamp_2
%             times_stamp_2 = xdfmarkers{i_markerstream}.time_stamps(find(xdfmarkers{i_markerstream}.time_stamps< xdfeeg{1}.time_stamps(end),1,'last'));
%             event_2 = xdfmarkers{i_markerstream}.time_series(find(xdfmarkers{i_markerstream}.time_stamps< xdfeeg{1}.time_stamps(end),1,'last'));
%         end
%         
%     end
%     
%     for i=1:length(xdfeeg)
%         eeg_times_1{i} = find(xdfeeg{i}.time_stamps > times_stamp_1-1 & xdfeeg{i}.time_stamps < times_stamp_1+2);
%         eeg_times_2{i} = find(xdfeeg{i}.time_stamps > times_stamp_2-1 & xdfeeg{i}.time_stamps < times_stamp_2+2);
%     end
%     
%     for i=1:length(xdfmotion)
%         motion_times_1{i} = find(xdfmotion{i}.time_stamps > times_stamp_1-1 & xdfmotion{i}.time_stamps < times_stamp_1+2);
%         motion_times_2{i} = find(xdfmotion{i}.time_stamps > times_stamp_2-1 & xdfmotion{i}.time_stamps < times_stamp_2+2);
%     end
%     
%     for i=1:length(xdfphysio)
%         physio_times_1{i} = find(xdfphysio{i}.time_stamps > times_stamp_1-1 & xdfphysio{i}.time_stamps < times_stamp_1+2);
%         physio_times_2{i} = find(xdfphysio{i}.time_stamps > times_stamp_2-1 & xdfphysio{i}.time_stamps < times_stamp_2+2);
%     end
%     
%     raw_fig = figure('color','w','position',[1 1 1920 1080]);
%     sgtitle(['Raw data from ' cfg.dataset],'interpreter','none')
%     
%     subplot(211); hold on; grid on; grid(gca,'minor')
%     title(strjoin(['First event: "' event_1 '"']),'interpreter','none')
%     yticks(-1)
%     yticklabels('')
%     plot([times_stamp_1 times_stamp_1]-times_stamp_1, [-1 100], 'k')
%     
%     xaxistimes = eeg_times_1{1};
%     if ~isempty(xaxistimes)
%         xlim([xdfeeg{1}.time_stamps(xaxistimes(1))  xdfeeg{1}.time_stamps(xaxistimes(end)) ]-times_stamp_1)
%     end
%     
%     for i=1:length(xdfeeg)
%         my_yticks = yticks;
%         plot(xdfeeg{i}.time_stamps(xaxistimes)-times_stamp_1 ,normalize(xdfeeg{i}.time_series(1,xaxistimes),...
%             'range',[my_yticks(end)+1 my_yticks(end)+2]), 'color', [78 165 216]/255)
%         yticks([yticks my_yticks(end)+1.5])
%         yticklabels([yticklabels
%             strrep([xdfeeg{1}.info.name ' ' xdfeeg{1}.info.desc.channels.channel{1}.label],'_', ' ')]);
%         ylim([-0.5 my_yticks(end)+2.5])
%     end
%     xlabel('seconds')
%     
%     for i=1:length(xdfmotion)
%         
%         allchanlabels = {};
%         for i_chan = 1:length(xdfmotion{i}.info.desc.channels.channel)
%             allchanlabels{end+1} = xdfmotion{i}.info.desc.channels.channel{i_chan}.label;
%         end
%         
%         idx = find(~contains(allchanlabels,'eul') & ~contains(allchanlabels,'quat') &...
%             ~contains(allchanlabels,'ori'),1,'first');
%         
%         my_yticks = yticks;
%         plot(xdfmotion{i}.time_stamps(motion_times_1{i})-times_stamp_1 ,normalize(xdfmotion{i}.time_series(idx,motion_times_1{i}),...
%             'range',[my_yticks(end)+1 my_yticks(end)+2]), 'color', [78 165 216]/255)
%         yticks([yticks my_yticks(end)+1.5])
%         yticklabels([yticklabels
%             strrep([xdfmotion{i}.info.name ' ' xdfmotion{i}.info.desc.channels.channel{idx}.label],'_', ' ')]);
%         ylim([-0.5 my_yticks(end)+2.5])
%     end
%     
%     for i=1:length(xdfphysio)
%         my_yticks = yticks;
%         plot(xdfphysio{i}.time_stamps(physio_times_1{i})-times_stamp_1 ,normalize(xdfphysio{i}.time_series(1,physio_times_1{i}),...
%             'range',[my_yticks(end)+1 my_yticks(end)+2]), 'color', [78 165 216]/255)
%         yticks([yticks my_yticks(end)+1.5])
%         yticklabels([yticklabels
%             strrep([xdfphysio{i}.info.name ' ' xdfphysio{i}.info.desc.channels.channel{1}.label],'_', ' ')]);
%         ylim([-0.5 my_yticks(end)+2.5])
%     end
%     
%     ax = gca;
%     ax.YAxis.MinorTickValues = ax.YAxis.Limits(1):0.2:ax.YAxis.Limits(2);
%     
%     subplot(212); hold on; grid on; grid(gca,'minor')
%     title(strjoin(['Last event: "' event_2 '"']),'interpreter','none')
%     yticks(-1)
%     yticklabels('')
%     plot([times_stamp_2 times_stamp_2]-times_stamp_2, [-1 100], 'k')
%     
%     xaxistimes = eeg_times_2{1};
%     if ~isempty(xaxistimes)
%         xlim([xdfeeg{1}.time_stamps(xaxistimes(1))  xdfeeg{1}.time_stamps(xaxistimes(end)) ]-times_stamp_2)
%     end
%     
%     for i=1:length(xdfeeg)
%         my_yticks = yticks;
%         plot(xdfeeg{i}.time_stamps(xaxistimes)-times_stamp_2 ,normalize(xdfeeg{i}.time_series(1,xaxistimes),...
%             'range',[my_yticks(end)+1 my_yticks(end)+2]), 'color', [78 165 216]/255)
%         yticks([yticks my_yticks(end)+1.5])
%         yticklabels([yticklabels
%             strrep([xdfeeg{1}.info.name ' ' xdfeeg{1}.info.desc.channels.channel{1}.label],'_', ' ')]);
%         ylim([-0.5 my_yticks(end)+2.5])
%     end
%     xlabel('seconds')
%     
%     for i=1:length(xdfmotion)
%         
%         allchanlabels = {};
%         for i_chan = 1:length(xdfmotion{i}.info.desc.channels.channel)
%             allchanlabels{end+1} = xdfmotion{i}.info.desc.channels.channel{i_chan}.label;
%         end
%         
%         idx = find(~contains(allchanlabels,'eul') & ~contains(allchanlabels,'quat') &...
%             ~contains(allchanlabels,'ori'),1,'first');
%         
%         my_yticks = yticks;
%         plot(xdfmotion{i}.time_stamps(motion_times_2{i})-times_stamp_2 ,normalize(xdfmotion{i}.time_series(idx,motion_times_2{i}),...
%             'range',[my_yticks(end)+1 my_yticks(end)+2]), 'color', [78 165 216]/255)
%         yticks([yticks my_yticks(end)+1.5])
%         yticklabels([yticklabels
%             strrep([xdfmotion{i}.info.name ' ' xdfmotion{i}.info.desc.channels.channel{idx}.label],'_', ' ')]);
%         ylim([-0.5 my_yticks(end)+2.5])
%     end
%     
%     for i=1:length(xdfphysio)
%         my_yticks = yticks;
%         plot(xdfphysio{i}.time_stamps(physio_times_2{i})-times_stamp_2 ,normalize(xdfphysio{i}.time_series(1,physio_times_2{i}),...
%             'range',[my_yticks(end)+1 my_yticks(end)+2]), 'color', [78 165 216]/255)
%         yticks([yticks my_yticks(end)+1.5])
%         yticklabels([yticklabels
%             strrep([xdfphysio{i}.info.name ' ' xdfphysio{i}.info.desc.channels.channel{1}.label],'_', ' ')]);
%         ylim([-0.5 my_yticks(end)+2.5])
%     end
%     
%     ax = gca;
%     ax.YAxis.MinorTickValues = ax.YAxis.Limits(1):0.2:ax.YAxis.Limits(2);
%     
%     [filepath,name,~] = fileparts(cfg.dataset);
%     savefig(raw_fig,fullfile(filepath,[name '_raw-data']))
%     print(raw_fig,fullfile(filepath,[name '_raw-data']),'-dpng')
%     close(raw_fig)
%     
% else
%     warning('NO MARKERS IN THE FILE! NO PLOT CAN BE CREATED')
% end
%%
if importEEG % This loop is always executed in current version
    
    %----------------------------------------------------------------------
    %                   Convert EEG Data to BIDS
    %----------------------------------------------------------------------
    
    % construct fieldtrip data
    eeg        = stream2ft(xdfeeg{1});
    
    % save eeg start time
    eegStartTime                = eeg.time{1}(1);
    
    % eeg metadata construction
    %----------------------------------------------------------------------
    eegcfg                              = cfg;
    eegcfg.datatype                     = 'eeg';
    eegcfg.method                       = 'convert';
    
    % default coordinate system files
    if isfield(config.eeg, 'chanloc')
        if ~isempty(config.eeg.chanloc)
            eegcfg.coordsystem.EEGCoordinateSystem      = 'n/a';
            eegcfg.coordsystem.EEGCoordinateUnits       = 'mm';
        end
    elseif isfield(config.eeg, 'elec_struct')
        if ~isempty(config.eeg.elec_struct)
            eegcfg.coordsystem.EEGCoordinateSystem      = 'n/a';
            eegcfg.coordsystem.EEGCoordinateUnits       = 'mm';
        end
    end
    
    % try to use metadata provided by the user - if provided, will overwrite values from config.
    if exist('eegInfo','var')
        if isfield(eegInfo, 'eeg')
            eegcfg.eeg          = eegInfo.eeg;
        end
        if isfield(eegInfo, 'coordsystem')
            eegcfg.coordsystem  = eegInfo.coordsystem;
        end
    end
    
    % try to use information from preprocessing config
    if isfield(config.eeg, 'ref_channel')
        eegcfg.eeg.EEGReference                 = config.eeg.ref_channel; % field name comes from bemobil preprocessing pipeline
    end
    if isfield(config.eeg, 'srate')
        eegcfg.eeg.SamplingFrequency                 = config.eeg.srate; % field name comes from bemobil preprocessing pipeline
    end
    if isfield(config.eeg, 'linefreq')
        if numel(config.eeg.linefreq) == 1
            eegcfg.eeg.PowerLineFrequency           = config.eeg.linefreq; % field name comes from bemobil preprocessing pipeline
        elseif numel(config.eeg.linefreq) > 1
            eegcfg.eeg.PowerLineFrequency           = config.eeg.linefreq(1);
            warning('Only the first value specified in config.eeg.linefreq entered in eeg.json')
        end
    end
    
    % if specified, replace labels of the read eeg stream
    if isfield(config.eeg, 'channel_labels')
        eeg.label = config.eeg.channel_labels;
    end
    
    % check if mandatory fields are specified and if not, fill with default values
    if isfield(eegcfg, 'eeg')
        [eegcfg.eeg] =  checkfield(eegcfg.eeg, 'EEGReference', 'REF', 'REF');
        [eegcfg.eeg] =  checkfield(eegcfg.eeg, 'PowerLineFrequency', 'n/a', 'n/a');
        [eegcfg.eeg] =  checkfield(eegcfg.eeg, 'SoftwareFilters', 'n/a', 'n/a');
    else
        eegcfg.eeg.EEGReference = 'REF';
        eegcfg.eeg.PowerLineFrequency = 'n/a';
        eegcfg.eeg.SoftwareFilters = 'n/a';
    end
    
    % check if sampling frequency was specified, if it was not, use nominal srate from the stream
    if ~isfield(eegcfg.eeg,'SamplingFrequency') || isempty(eegcfg.eeg.SamplingFrequency) || strcmp(eegcfg.eeg.SamplingFrequency,'n/a')
        warning('EEG sampling frequency was not specified. Using nominal srate taken from xdf!')
        eegcfg.eeg.SamplingFrequency = str2num(xdfeeg{1}.info.nominal_srate);
    elseif ~isnumeric(eegcfg.eeg.SamplingFrequency) || eegcfg.eeg.SamplingFrequency < 0
        warning('EEG sampling freq is:')
        disp(eegcfg.eeg.SamplingFrequency)
        error('Specified EEG sampling frequency is not supported. Must be empty, ''n/a'', or numeric greater 0.')
    end
    disp(['EEG sampling frequency is ' num2str(eegcfg.eeg.SamplingFrequency) 'Hz.'])
    
    % read in the event stream (synched to the EEG stream)
    eventsFound = 0;
    if ~isempty(xdfmarkers)
        
        if any(cellfun(@(x) ~isempty(x.time_series), xdfmarkers))
            
            events                  = stream2events(xdfmarkers, xdfeeg{1}.time_stamps);
            eventsFound             = 1;
            
            % event parser script
            if isfield(config, 'bids_parsemarkers_custom')
                if isempty(config.bids_parsemarkers_custom)
                    [events, eventsJSON] = bemobil_bids_parsemarkers(events);
                else
                    [events, eventsJSON] = feval(config.bids_parsemarkers_custom, events);
                end
            else
                [events, eventsJSON] = bemobil_bids_parsemarkers(events);
            end
            
            eegcfg.events = events;
            
        end
    end
    
    if isfield(config.eeg, 'elec_struct') && ~isempty(config.eeg.elec_struct)
        eegcfg.elec                         = config.eeg.elec_struct;
    elseif isfield(config.eeg, 'chanloc') && ~isempty(config.eeg.chanloc)
        try
            elec = ft_read_sens(config.eeg.chanloc);
        catch
            error(['Could not read electrode locations from file "' config.eeg.chanloc '"'])
        end

        eegcfg.elec = elec; 
        if isfield(config.eeg, 'location_labels')
            eegcfg.elec.label = config.eeg.location_labels; 
        end
    end
    
    % acquisition time processing
    eegcfg.scans.acq_time = datenum(config.acquisition_time);
    eegcfg.scans.acq_time = datestr(eegcfg.scans.acq_time,'yyyy-mm-ddTHH:MM:SS.FFF'); % milisecond precision
    
    
    % write eeg files in bids format
    data2bids(eegcfg, eeg);
    
end

%%
% add general json files
%--------------------------------------------------------------------------
ft_hastoolbox('jsonlab', 1);

if exist('subjectInfo', 'var') && ~isempty(subjectInfo)
    % participant.json
    pJSONName       = fullfile(cfg.bidsroot, 'participants.json');
    pfid            = fopen(pJSONName, 'wt');
    pString         = savejson('', subjectInfo.fields, 'NaN', '"n/a"', 'ParseLogical', true);
    fwrite(pfid, pString); fclose(pfid);
end

if eventsFound
    % events.json
    eJSONName       = fullfile(cfg.bidsroot, ['task-' cfg.task '_events.json']);
    efid            = fopen(eJSONName, 'wt');
    eString         = savejson('', eventsJSON, 'NaN', '"n/a"', 'ParseLogical', true);
    fwrite(efid, eString); fclose(efid);
end

disp('XDF to BIDS conversion finished.')

end


%--------------------------------------------------------------------------
function [newconfig] =  checkfield(oldconfig, fieldName, defaultValue, defaultValueText)
% This function checks for existence of required fields
% for optional fields that have default values, assign them

% throw an error if a required field has not been specified
if strcmp(defaultValue, 'required')
    if ~isfield(oldconfig, fieldName)
        error(['Required config field ' fieldName ' not specified'])
    end
end

% assign default value to an optional field
newconfig   = oldconfig;

if ~isfield(oldconfig, fieldName)
    newconfig.(fieldName) = defaultValue;
    warning(['Config field ' fieldName ' not specified - using default value: ' defaultValueText])
end


end

%--------------------------------------------------------------------------
function [ftdata] = stream2ft(xdfstream)

% construct header
hdr.Fs                  = xdfstream.info.effective_srate;
hdr.nFs                 = str2double(xdfstream.info.nominal_srate);
hdr.nSamplesPre         = 0;
hdr.nSamples            = length(xdfstream.time_stamps);
hdr.nTrials             = 1;
hdr.FirstTimeStamp      = xdfstream.time_stamps(1);
hdr.TimeStampPerSample  = (xdfstream.time_stamps(end)-xdfstream.time_stamps(1)) / (length(xdfstream.time_stamps) - 1);
if isfield(xdfstream.info.desc, 'channels')
    hdr.nChans    = numel(xdfstream.info.desc.channels.channel);
else
    hdr.nChans    = str2double(xdfstream.info.channel_count);
end

hdr.label       = cell(hdr.nChans, 1);
hdr.chantype    = cell(hdr.nChans, 1);
hdr.chanunit    = cell(hdr.nChans, 1);

prefix = xdfstream.info.name;
for j=1:hdr.nChans
    if isfield(xdfstream.info.desc, 'channels')
        hdr.label{j} = [prefix '_' xdfstream.info.desc.channels.channel{j}.label];
        
        try
            hdr.chantype{j} = xdfstream.info.desc.channels.channel{j}.type;
        catch
            disp([hdr.label{j} ' missing type'])
        end
        
        try
            hdr.chanunit{j} = xdfstream.info.desc.channels.channel{j}.unit;
        catch
            disp([hdr.label{j} ' missing unit'])
        end
    else
        % the stream does not contain continuously sampled data
        hdr.label{j} = num2str(j);
        hdr.chantype{j} = 'unknown';
        hdr.chanunit{j} = 'unknown';
    end
end

% keep the original header details
hdr.orig = xdfstream.info;

ftdata.trial    = {xdfstream.time_series};
ftdata.time     = {xdfstream.time_stamps};
ftdata.hdr = hdr;
ftdata.label = hdr.label;

end

function outEvents = stream2events(inStreams, dataTimes)

outEvents = [];

for Si = 1:numel(inStreams)
    if iscell(inStreams{Si}.time_series)
        eventsInStream              = cell2struct(inStreams{Si}.time_series, 'value')';
        
        % remove linebreaks
        for i_event = find(contains(inStreams{Si}.time_series,char(10)))
            eventsInStream(i_event).value = strrep(eventsInStream(i_event).value,char(10),' ');
        end
        
        % remove tabs
        for i_event = find(contains(inStreams{Si}.time_series,char(9)))
            eventsInStream(i_event).value = strrep(eventsInStream(i_event).value,char(9),' ');
        end
        
        % remove other kinds of linebreaks
        for i_event = find(contains(inStreams{Si}.time_series,char(13)))
            eventsInStream(i_event).value = strrep(eventsInStream(i_event).value,char(13),' ');
        end
        
        [eventsInStream.type]       = deal(inStreams{Si}.info.type);
        times                       = num2cell(inStreams{Si}.time_stamps);
        [eventsInStream.timestamp]  = times{:};
        samples                     = cellfun(@(x) find(dataTimes >= x, 1,'first'), times, 'UniformOutput', false);
        [eventsInStream.sample]     = samples{:};
        [eventsInStream.offset]     = deal([]);
        [eventsInStream.duration]   = deal([]);
        outEvents = [outEvents eventsInStream];
    end
end

% sort events by sample
[~,I] = sort([outEvents.timestamp]);
outEvents   = outEvents(I);

% re-order fields to match ft events output
outEvents   = orderfields(outEvents, [2,1,3,4,5,6]);

end


function y = checkequal(x)
% Input 'x' should be cell array
% Output 'y' logical value true. If any input cell array index is equal to
% another else false
% Example1:
% a{1}=[1 1 0]; a{2}=[0 0 0]; a{3}=[0 0 0];
% y = checkequal(a);
% Output is y = logical(1)
% Example2:
% a{1}=[1 1 0]; a{2}=[0 1 0]; a{3}=[0 0 0];
% y = checkequal(a);
% Output is y = logical(0)
y = false;
num = numel(x);
for i = 1:num
    for j = 1:num
        if i~=j
            if isequal(x{i},x{j})
                y = true;
                return;
            end
        end
    end
end

end
