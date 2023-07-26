% Data: EPOC (Walter Maetzler, University of Kiel)
% Author: Christian Neumann (Christian.Neumann@uksh.de)

%% 1. Start up

clc; clear all; close all;

filepath = fileparts(fileparts(pwd));
cd (filepath);

MAIN = [pwd '\'];
addpath(genpath(MAIN));
addpath('C:\Users\Chris\Documents\fieldtrip-20230118');

% Change MatLab defaults
set(0,'defaultfigurecolor',[1 1 1]);

% initiate Fieldtrip
ft_defaults;

% Set envir
PATHIN      = [MAIN '02_data\00_bids\sourcedata\'];
PATHOUT     = [MAIN '02_data\01_prep\'];

if ~isdir(PATHOUT);mkdir(PATHOUT);end

%% 2. Read data and split it
patient             = dir(PATHIN);
patient([1,2],:)    = [];

for p = 1:numel(patient.name)

    cd([PATHIN patient(p).name filesep 'eeg']);
    indat   = dir('*xdf');

    for d = 1:numel(indat)

        cfg = [];
        cfg.dataset         = [PATHIN patient(p).name filesep 'eeg' filesep indat(d).name];
        cfg.trialfun        = 'oddball_trialfun_events';
        [data, events]      = xdf2fieldtrip(cfg.dataset);
        cfg.trialdef.pre    = 1;
        cfg.trialdef.post   = 1;
        
        cfg = ft_definetrial(cfg); 
        
        % save the trial-definition
        trl = cfg.trl;
        
        %% 3. preprocessing
        % define entire dataset as one trial for filtering 
        cfg = [];
        cfg.dataset         = [PATHIN patient(p).name filesep 'eeg' filesep indat(d).name];
        cfg.trialfun        = 'trialfun_fulldata';
        
        cfg = ft_definetrial(cfg); 
        
        % which Filter to use
        cfg.demean      = 'yes';    % remove DC offset
        cfg.hpfilter    = 'yes';
        cfg.hpfreq      = .1;       % high-pass filter, cutting everything under .5 Hz
        cfg.hpfilttype  = 'firws';
        cfg.lpfilter    = 'yes';
        cfg.lpfreq      = 35;       % low-pass filter, cutting everything over 45 Hz (ausprobieren und plotten, um noise rauszukriegen) 
        cfg.lpfilttype  = 'firws';
        cfg.pad         = 'nextpow2';
        
        data_p = ft_preprocessing(cfg); % save processed data
        
        % Cut the data according to the trial definition
        cfg = [];
        cfg.trl = trl; % Use the trl-structure defined above
        
        data_t = ft_redefinetrial(cfg,data_p);
        
        %% Change channel names
        for c = 1:length(data_t.label)
            data_t.label{c} = data_t.hdr.orig.desc.channels.channel{c}.label;
        end
        
        %% Take a look at the data
        
        cfg = []; % empty the cfg-structure
        cfg.viewmode = 'vertical'; % or butterfly
        
        ft_databrowser(cfg,data_t);
        
        %% 4. clean data
        
        % visual artefact rejection 
        cfg = [];
        load('BC-128-pass-lay.mat');
        cfg.elec                = elec;
        layout                  = ft_prepare_layout(cfg);
        cfg.layout              = layout;

        cfg.method              = 'summary';
        cfg.keepchannel         = 'no'; % Remove Bad channels
        % We can also specify filters just for the artifact rejection
        % These settings are good to identify eye blinks
        cfg.preproc.bpfilter    = 'yes';
        cfg.preproc.bpfilttype  = 'but';
        cfg.preproc.bpfreq      = [1 15];
        cfg.preproc.bpfiltord   = 4;
        cfg.preproc.rectify     = 'yes';
        
        data_c = ft_rejectvisual(cfg,data_t);
        
        %% 5. Re-Reference
        
        % After cleaning the data, it is best to re-reference the data to
        % the average across channels to remove the influence of the
        % reference
        
        cfg = [];
        cfg.reref = 'yes';
        cfg.refchannel = 1:length(data_c.label)-1; % Take all channels
        cfg.refmethod = 'avg'; % Take the average
        
        data_c = ft_preprocessing(cfg,data_c);
        
        %% 6. Compute ICA-Components
        
        cfg = [];
        %cfg.channel = {'e*'}; % Super important to only use the EEG-Channels, otherwise the ICA won't work
        cfg.method = 'runica'; % Whcih method should be used? 
        cfg.runica.pca = size(data_c.trial{1},1)-1; % Reduce the data dimensions to the number of channels-1
        %cfg.runica.extended = 1; % If there is lot of line-nois (50Hz)
        %include subgaussian noise
        %cfg.numcomponents = 20; % if the ICA does not converge, limit the number of components to compute
        cfg.demean = 'yes'; % remove trial-wise offset
        
        comp = ft_componentanalysis(cfg,data_c);
        
        %% Take a look at the components
        
        cfg = [];
        cfg.layout = layout;
        cfg.viewmode = 'component'; % same as above, just with a different mode
        cfg.allowoverlap = 'yes';
        
        ft_databrowser(cfg,comp);
        
        % Here, you'll actually have to write down or remember the bad
        % components
        
        %% And take out the ones that are clearly artefacts
        
        cfg = [];
        cfg.component = [1,2,3]; % I focus on blinks and muscle artefacts
        data_ci = ft_rejectcomponent(cfg,comp,data_c);
        
        %% Compare before & after
        
        figure;plot(data_ci.time{1},data_ci.trial{5}(1,:),'r');hold;plot(data_c.time{1},data_c.trial{5}(1,:),'b')
        
        %% Neighbors
        
        cfg = []; 
        cfg.method = 'distance'; % how should the neighbors be selected?
        cfg.neighbourdist = 0.5; % I have no Idea what range this has, just make sure, that you get meaningful neighbors
        cfg.elec = elec;
        
        neigh = ft_prepare_neighbours(cfg); % between 5 and 10 neighbors is a good value, always good to check!
            
        %% Check!
        cfg = [];
        cfg.neighbours = neigh; % what neighbor-structure
        cfg.elec = elec;
        
        ft_neighbourplot(cfg)
        % Again, ist's best to check the actual neighbors for each channel. On
        % average you'll want to end up with ahout 5 to 10 neighbors for each
        % channel, at least have 2, otherwise you'll just end up copying one
        % channel.
        
        %% Repair the Cleaned and ICA-Corrected Data
        
        % For further analyses, it is helpful if all subjects have the same number
        % of channels.
        cfg=[];
        cfg.method = 'spline';
        cfg.missingchannel = setdiff(data_t.label,data_ci.label);%{'e52' 'e72' 'e88'}; % Who's bad?
        cfg.neighbours = neigh; % What channels should be used to fix?
        cfg.elec = elec; % Where are the channels?
        
        data_cif=ft_channelrepair(cfg,data_ci);
        
        %% ERP calculation 
        
        cfg = [];
        cfg.trials = find(data_c.trialinfo == 1);
        ERP_target = ft_timelockanalysis(cfg,data_c);
        
        
        
        %% averaged ERP
        
        cfg = [];
        figure;
        ft_singleplotER(cfg, ERP_target);
        
        hold on;
        title ('averaged ERP');
        xlabel('Time (s)');
        ylabel('Electric Potential (V)');
    end
end