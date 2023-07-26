%% 1. Start up

clc; clear all; close all;

filepath = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
cd (filepath);

MAIN = [pwd filesep];
addpath(genpath(MAIN));
addpath('C:\Users\Chris\Documents\fieldtrip-20230118');

% Change MatLab defaults
set(0,'defaultfigurecolor',[1 1 1]);

% initiate Fieldtrip
ft_defaults;

%% Set envir

PATHIN      = [MAIN '02_data\00_bids\sourcedata\'];
PATHOUT     = [MAIN '02_data\01_prep\'];

if ~isdir(PATHOUT);mkdir(PATHOUT);end

%% Prepare variables
oddball_rt          = [];
oddball_miss        = [];
oddball_false_alarm = [];
rte_rt_A            = [];
rte_rt_V            = [];
rte_rt_AV           = [];
rte_miss            = [];
pvt_rt              = [];
nback_rt_1          = [];
nback_miss_1        = [];
nback_false_alarm_1 = [];
nback_rt_2          = [];
nback_miss_2        = [];
nback_false_alarm_2 = [];
pp                  = tdfread([fileparts(fileparts(PATHIN)) filesep 'participants.tsv']);

%%
for p = 1:size(pp.participant_id,1)
    cd([PATHIN pp.participant_id(p,:)]);
    folder = dir;
    folder([1,2],:) = [];

    pvt{p}                  = [];
    oddball{p}              = [];
    rte{p}                  = [];
    nback{p}                = [];

    for o = 1:numel(folder)
        cd(fullfile([PATHIN pp.participant_id(p,:)], folder(o).name));
        indat   = dir('*xdf');
    
        for d = 1:numel(indat)
            %% general specification 
            %------------------------------------------------------------------
            config                                                  = [];
            config.filename                                         = indat(d).name;
            config.bids_target_folder                               = [MAIN '02_data\00_bids'];
            config.subject                                          = p;
            config.task                                             = extractBefore(extractAfter(indat(d).name,16),'_');
            
            %% task-specific specification
            %------------------------------------------------------------------
            if string(config.task) == "oddball"
                generalInfo.task                                    = 'oddball';
                generalInfo.dataset_description.Name                = 'oddball';
            elseif string(config.task) == "rte"
                generalInfo.task                                    = 'rte';
                generalInfo.dataset_description.Name                = 'rte';
            elseif string(config.task) == "pvt"
                generalInfo.task                                    = 'pvt';
                generalInfo.dataset_description.Name                = 'pvt';
            elseif string(config.task) == "nback"
                generalInfo.task                                    = 'nback';
                generalInfo.dataset_description.Name                = 'nback';
            end
            
            %% EEG parameters
            %------------------------------------------------------------------
            
            config.eeg.stream_name                                  = 'BrainVision';
            %config.eeg.chanloc             = optional, string, full path to the channel location file
            %config.eeg.location_labels     = {'chan1', 'chan2', ...};            % optional, cell array of size nchan X 1, replace channel names in the location file   
            %config.eeg.channel_labels      = {'chan1', 'chan2', ...};            % optional, cell array of size nchan X 1, replace channel names in the xdf file
            eeg_info.eeg.PowerLineFrequency                         = 50;    
            
            %% BEH parameters
            %------------------------------------------------------------------
            %% paper & pencil tasks

            age             = pp.age(p,:);
            sex             = pp.sex(p,:);
            group           = pp.group(p,:);
            eyesight        = pp.eyesight(p,:);
            graduation      = pp.graduation(p,:);
            years           = pp.years_of_education(p,:);
            neurological_1  = pp.neurological_diseases_1(p,:);
            neurological_2  = pp.neurological_diseases_2(p,:);
            other           = pp.other_diseases(p,:);
            tmt_a_time      = pp.tmt_a_time(p,:);
            tmt_b_time      = pp.tmt_b_time(p,:);
            tmt_a_mistakes  = pp.tmt_a_mistakes(p,:);
            tmt_b_mistakes  = pp.tmt_b_mistakes(p,:);
            facitf_GP1      = pp.facit_f_GP1(p,:);
            facitf_GP2      = pp.facit_f_GP2(p,:);
            facitf_GP3      = pp.facit_f_GP3(p,:);
            facitf_GP4      = pp.facit_f_GP4(p,:);
            facitf_GP5      = pp.facit_f_GP5(p,:);
            facitf_GP6      = pp.facit_f_GP6(p,:);
            facitf_GP7      = pp.facit_f_GP7(p,:);
            facitf_GS1      = pp.facit_f_GS1(p,:);
            facitf_GS2      = pp.facit_f_GS2(p,:);
            facitf_GS3      = pp.facit_f_GS3(p,:);
            facitf_GS4      = pp.facit_f_GS4(p,:);
            facitf_GS5      = pp.facit_f_GS5(p,:);
            facitf_GS6      = pp.facit_f_GS6(p,:);
            facitf_GS7      = pp.facit_f_GS7(p,:);
            facitf_GE1      = pp.facit_f_GE1(p,:);
            facitf_GE2      = pp.facit_f_GE2(p,:);
            facitf_GE3      = pp.facit_f_GE3(p,:);
            facitf_GE4      = pp.facit_f_GE4(p,:);
            facitf_GE5      = pp.facit_f_GE5(p,:);
            facitf_GE6      = pp.facit_f_GE6(p,:);
            facitf_GF1      = pp.facit_f_GF1(p,:);
            facitf_GF2      = pp.facit_f_GF2(p,:);
            facitf_GF3      = pp.facit_f_GF3(p,:);
            facitf_GF4      = pp.facit_f_GF4(p,:);
            facitf_GF5      = pp.facit_f_GF5(p,:);
            facitf_GF6      = pp.facit_f_GF6(p,:);
            facitf_GF7      = pp.facit_f_GF7(p,:);
            facitf_HI7      = pp.facit_f_HI7(p,:);
            facitf_HI12      = pp.facit_f_HI12(p,:);
            facitf_An1      = pp.facit_f_An1(p,:);
            facitf_An2      = pp.facit_f_An2(p,:);
            facitf_An3      = pp.facit_f_An3(p,:);
            facitf_An4      = pp.facit_f_An4(p,:);
            facitf_An5      = pp.facit_f_An5(p,:);
            facitf_An7      = pp.facit_f_An7(p,:);
            facitf_An8      = pp.facit_f_An8(p,:);
            facitf_An12      = pp.facit_f_An12(p,:);
            facitf_An14      = pp.facit_f_An14(p,:);
            facitf_An15      = pp.facit_f_An15(p,:);
            facitf_An16      = pp.facit_f_An16(p,:);

            facitf_pwb      = calc_pwb(facitf_GP1,facitf_GP2,facitf_GP3,facitf_GP4,facitf_GP5,facitf_GP6,facitf_GP7);
            facitf_swb      = calc_swb(facitf_GS1,facitf_GS2,facitf_GS3,facitf_GS4,facitf_GS5,facitf_GS6,facitf_GS7);
            facitf_ewb      = calc_ewb(facitf_GE1,facitf_GE2,facitf_GE3,facitf_GE4,facitf_GE5,facitf_GE6);
            facitf_fwb      = calc_fwb(facitf_GF1,facitf_GF2,facitf_GF3,facitf_GF4,facitf_GF5,facitf_GF6,facitf_GF7);
            facitf_fs      = calc_fs(facitf_HI7,facitf_HI12,facitf_An1,facitf_An2,facitf_An3,facitf_An4,facitf_An5,facitf_An7,facitf_An8,facitf_An12,facitf_An14,facitf_An15,facitf_An16);
            facitf_toi      = facitf_pwb+facitf_fwb+facitf_fs;
            factg_ts      = facitf_pwb+facitf_ewb+facitf_fwb+facitf_swb;
            facitf_ts       = facitf_pwb+facitf_ewb+facitf_fwb+facitf_swb+facitf_fs;

            hadsd_1         = pp.hads_d_1(p,:);
            hadsd_2         = pp.hads_d_2(p,:);
            hadsd_3         = pp.hads_d_3(p,:);
            hadsd_4         = pp.hads_d_4(p,:);
            hadsd_5         = pp.hads_d_5(p,:);
            hadsd_6         = pp.hads_d_6(p,:);
            hadsd_7         = pp.hads_d_7(p,:);
            hadsd_8         = pp.hads_d_8(p,:);
            hadsd_9         = pp.hads_d_9(p,:);
            hadsd_10        = pp.hads_d_10(p,:);
            hadsd_11        = pp.hads_d_11(p,:);
            hadsd_12        = pp.hads_d_12(p,:);
            hadsd_13        = pp.hads_d_13(p,:);
            hadsd_14        = pp.hads_d_14(p,:);

            hadsa_ts        = calc_hadsa(hadsd_1,hadsd_3,hadsd_5,hadsd_7,hadsd_9,hadsd_11,hadsd_13);
            hadsd_ts        = calc_hadsd(hadsd_2,hadsd_4,hadsd_6,hadsd_8,hadsd_10,hadsd_12,hadsd_14);

            psqi_1          = pp.psqi_1(p,:);
            psqi_2          = pp.psqi_2(p,:);
            psqi_3          = pp.psqi_3(p,:);
            psqi_4          = pp.psqi_4(p,:);
            psqi_5a          = pp.psqi_5a(p,:);
            psqi_5b         = pp.psqi_5b(p,:);
            psqi_5c          = pp.psqi_5c(p,:);
            psqi_5d         = pp.psqi_5d(p,:);
            psqi_5e         = pp.psqi_5e(p,:);
            psqi_5f          = pp.psqi_5f(p,:);
            psqi_5g         = pp.psqi_5g(p,:);
            psqi_5h          = pp.psqi_5h(p,:);
            psqi_5i          = pp.psqi_5i(p,:);
            psqi_5j1          = pp.psqi_5j1(p,:);
            psqi_5j2          = pp.psqi_5j2(p,:);
            psqi_6          = pp.psqi_6(p,:);
            psqi_7          = pp.psqi_7(p,:);
            psqi_8          = pp.psqi_8(p,:);
            psqi_9          = pp.psqi_9(p,:);
            psqi_10          = pp.psqi_10(p,:);
            psqi_10a          = pp.psqi_10a(p,:);
            psqi_10b          = pp.psqi_10b(p,:);
            psqi_10c          = pp.psqi_10c(p,:);
            psqi_10d          = pp.psqi_10d(p,:);
            psqi_10e          = pp.psqi_10e(p,:);

            psqi_K1         = str2num(extractAfter(psqi_6,1))-1;
            psqi_K2         = calc_K2(psqi_2, psqi_5a);
            psqi_K3         = calc_K3(psqi_4);
            psqi_K4         = calc_K4(psqi_1, psqi_3, psqi_4);
            psqi_K5         = calc_K5(psqi_5b, psqi_5c, psqi_5d, psqi_5e, psqi_5f, psqi_5g, psqi_5h, psqi_5i, psqi_5j2);
            psqi_K6         = str2num(extractAfter(psqi_7,1))-1;
            psqi_K7         = calc_K7(psqi_8, psqi_9);
            psqi_ts         = psqi_K1 + psqi_K2 + psqi_K3 + psqi_K4 + psqi_K5 + psqi_K6 + psqi_K7;


            %% computer tasks

            if string(config.task) == "oddball"
                % oddball task 
                oddball{p}                                          = oddball_beh(indat(d).name);
                oddball_rt{p}                                       = mean(oddball{p}.rt, 'omitnan');
                oddball_miss{p}                                     = sum(strcmp(oddball{p}.accuracy,'miss'));
                oddball_false_alarm{p}                              = sum(strcmp(oddball{p}.accuracy,'false Alarm'));  
            elseif isempty(oddball{p})
                oddball_rt{p}                                       = NaN;
                oddball_miss{p}                                     = NaN;
                oddball_false_alarm{p}                              = NaN;
            end
                
            if string(config.task) == "rte"
            % redundant target effect 
                rte{p}                                              = rte_beh(indat(d).name);
                rte_rt_A{p}                                         = mean(rte{p}.rt(rte{p}.modality=="A"), 'omitnan');
                rte_rt_V{p}                                         = mean(rte{p}.rt(rte{p}.modality=="V"), 'omitnan');
                rte_rt_AV{p}                                        = mean(rte{p}.rt(rte{p}.modality=="AV"), 'omitnan');
                rte_miss{p}                                         = sum(rte{p}.accuracy=="miss");
            elseif isempty(rte{p})
                rte_rt_A{p}                                         = NaN;
                rte_rt_V{p}                                         = NaN;
                rte_rt_AV{p}                                        = NaN;
                rte_miss{p}                                         = NaN;
            end

            if string(config.task) == "pvt"
                pvt{p}                                              = pvt_beh(indat(d).name);
                pvt_rt{p}                                           = mean(pvt{p}.rt);
            elseif isempty(pvt{p})
                pvt_rt{p}                                           = NaN;
            end

            if string(config.task) == "nback"
                nback{p}                                            = nback_beh(indat(d).name);
                nback_rt_1{p}                                         = mean(nback{p}.rt(1:60), 'omitnan');
                nback_miss_1{p}                                       = sum(strcmp(nback{p}.accuracy(1:60),'miss'));
                nback_false_alarm_1{p}                                = sum(strcmp(nback{p}.accuracy(1:60),'false Alarm'));
                nback_rt_2{p}                                         = mean(nback{p}.rt(60:end), 'omitnan');
                nback_miss_2{p}                                       = sum(strcmp(nback{p}.accuracy(60:end),'miss'));
                nback_false_alarm_2{p}                                = sum(strcmp(nback{p}.accuracy(60:end),'false Alarm'));
            elseif isempty(nback{p})
                nback_rt_1{p}                                         = NaN;
                nback_miss_1{p}                                       = NaN;
                nback_false_alarm_1{p}                                = NaN;
                nback_rt_2{p}                                         = NaN;
                nback_miss_2{p}                                       = NaN;
                nback_false_alarm_2{p}                                = NaN;
            end
            
            %% participant files 
            %------------------------------------------------------------------
            subject_info.fields.nr.Description                     = 'number of the participant'; 
            
            subject_info.fields.age.Description                     = 'age of the participant'; 
            subject_info.fields.age.Unit                            = 'years'; 
            
            subject_info.fields.sex.Description                     = 'sex of the participant'; 
            subject_info.fields.sex.Levels.M                        = 'male'; 
            subject_info.fields.sex.Levels.F                        = 'female';
            subject_info.fields.sex.Levels.D                        = 'diverse';
            subject_info.fields.sex.Levels.K                        = 'not specified ';
            
            subject_info.fields.group.Description                   = 'experiment group';
            subject_info.fields.group.Levels.withPCS                = 'participants with subjective cognitive impairment asked by trained medical staff during the COVIDOM study';
            subject_info.fields.group.Levels.withoutPCS             = 'participants without subjective cognitive impairment asked by trained medical staff during the COVIDOM study';
            
            subject_info.fields.eyesight.Description                = 'eyesight of the participant';
            subject_info.fields.eyesight.Levels.glasses             = 'participant was wearing glasses during experiment';
            subject_info.fields.eyesight.Levels.lenses              = 'participant was wearing contact lenses during experiment';
            subject_info.fields.eyesight.Levels.normal              = 'participant had regular eyesight without correction';
            
            subject_info.fields.graduation.Description              = 'highest graduation of the participant';
            subject_info.fields.graduation.Levels.H                 = 'Hauptschule';
            subject_info.fields.graduation.Levels.R                 = 'Realschule';
            subject_info.fields.graduation.Levels.FA                = 'Fachhochschulreife'
            subject_info.fields.graduation.Levels.A                 = 'Abitur';
            subject_info.fields.graduation.Levels.L                 = 'Lehre';
            subject_info.fields.graduation.Levels.F                 = 'Fachwirt';
            subject_info.fields.graduation.Levels.U                 = 'Universitätsabschluss';
            
            subject_info.fields.years_of_education.Description      = 'years of graduation of the participant as counted by the MoCA';
            subject_info.fields.years_of_education.Unit             = 'years'; 
            
            subject_info.fields.neurological_diseases_1.Description   = 'Does the participant have any previous neurological diseases';
            subject_info.fields.neurological_diseases_1.Levels.yes    = 'yes';
            subject_info.fields.neurological_diseases_1.Levels.no     = 'no';

            subject_info.fields.neurological_diseases_2.Description   = 'If they have any previous neurological diseases: which ones?';
            subject_info.fields.other_diseases.Description         = 'Which diseases does the participant currently have'
            
            subject_info.fields.tmt_a_time.Description              = 'time needed to finish TMT A'; 
            subject_info.fields.tmt_a_time.Unit                     = 'seconds';           
            subject_info.fields.tmt_b_time.Description              = 'time needed to finish TMT B'; 
            subject_info.fields.tmt_b_time.Unit                     = 'seconds';
            subject_info.fields.tmt_a_mistakes.Description          = 'number of mistakes that where made during completion of the TMT A'; 
            subject_info.fields.tmt_b_mistakes.Description          = 'number of mistakes that where made during completion of the TMT B';
            
            subject_info.fields.facit_f_PWB.Description             = 'sum of points in the physical well-being subscale of the FACIT-F questionnaire';
            subject_info.fields.facit_f_SWB.Description             = 'sum of points in the social/family well-being subscale of the FACIT-F questionnaire';
            subject_info.fields.facit_f_EWB.Description             = 'sum of points in the emotional well being subscale of the FACIT-F questionnaire';
            subject_info.fields.facit_f_FWB.Description             = 'sum of points in the functional well being subscale of the FACIT-F questionnaire';
            subject_info.fields.facit_f_FS.Description             = 'sum of points in the fatigue subscale of the FACIT-F questionnaire';
            subject_info.fields.facit_f_TOI.Description             = 'Trial Outcome Index of the FACIT-F questionnaire (PWB+FWB+FS)';
            subject_info.fields.fact_g_total_score.Description     = 'sum of points in the FACIT-F questionnaire without fatigue subscore(PWB+SWB+EWB+FWB)';

            subject_info.fields.facit_f_total_score.Description     = 'sum of points in the FACIT-F questionnaire. Lower scores mean lower quality of life';
            subject_info.fields.facit_f_GP1.Description             = 'Mir fehlt es an Energie';
            subject_info.fields.facit_f_GP1.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GP1.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GP1.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GP1.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GP1.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GP2.Description             = 'Mir ist übel';
            subject_info.fields.facit_f_GP2.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GP2.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GP2.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GP2.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GP2.Levels.A4                        = 'Sehr';            
            subject_info.fields.facit_f_GP3.Description             = 'Wegen meiner körperlichen Verfassung habe ich Schwierigkeiten, den Bedürfnissen meiner Familie gerecht zu werden';
            subject_info.fields.facit_f_GP3.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GP3.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GP3.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GP3.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GP3.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GP4.Description             = 'Ich habe Schmerzen';
            subject_info.fields.facit_f_GP4.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GP4.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GP4.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GP4.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GP4.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GP5.Description             = 'Die Nebenwirkungen der Behandlung machen mir zu schaffen';
            subject_info.fields.facit_f_GP5.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GP5.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GP5.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GP5.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GP5.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GP6.Description             = 'Ich fühle mich krank';
            subject_info.fields.facit_f_GP6.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GP6.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GP6.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GP6.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GP6.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GP7.Description             = 'Ich muss zeitweilig im Bett bleiben';
            subject_info.fields.facit_f_GP7.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GP7.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GP7.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GP7.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GP7.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GS1.Description             = 'Ich stehe meinen Freunden nahe';
            subject_info.fields.facit_f_GS1.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GS1.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GS1.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GS1.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GS1.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GS2.Description             = 'Ich bekomme seelische Unterstützung von meiner Familie';
            subject_info.fields.facit_f_GS2.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GS2.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GS2.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GS2.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GS2.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GS3.Description             = 'Ich bekomme Unterstützung von meinen Freunden"';
            subject_info.fields.facit_f_GS3.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GS3.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GS3.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GS3.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GS3.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GS4.Description             = '"Meine Familie hat meine Krankheit akzeptiert';
            subject_info.fields.facit_f_GS4.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GS4.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GS4.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GS4.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GS4.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GS5.Description             = 'Ich bin damit zufrieden, wie wir innerhalb meiner Familie über meine Krankheit reden';
            subject_info.fields.facit_f_GS5.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GS5.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GS5.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GS5.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GS5.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GS6.Description             = 'Ich fühle mich meinem Partner/meiner Partnerin oder der Person, die mir am nächsten steht, eng verbunden';
            subject_info.fields.facit_f_GS6.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GS6.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GS6.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GS6.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GS6.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GS7.Description             = 'Ich bin mit meinem Sexualleben zufrieden';
            subject_info.fields.facit_f_GS7.Levels.Q1                        = 'Keine Antwort'; 
            subject_info.fields.facit_f_GS7.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GS7.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GS7.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GS7.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GS7.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GE1.Description             = 'Ich bin traurig';
            subject_info.fields.facit_f_GE1.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GE1.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GE1.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GE1.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GE1.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GE2.Description             = 'Ich bin damit zufrieden, wie ich meine Krankheit bewältige';
            subject_info.fields.facit_f_GE2.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GE2.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GE2.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GE2.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GE2.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GE3.Description             = 'Ich verliere die Hoffnung im Kampf gegen meine Krankheit';
            subject_info.fields.facit_f_GE3.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GE3.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GE3.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GE3.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GE3.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GE4.Description             = 'Ich bin nervös';
            subject_info.fields.facit_f_GE4.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GE4.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GE4.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GE4.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GE4.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GE5.Description             = 'Ich mache mir Sorgen über den Tod';
            subject_info.fields.facit_f_GE5.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GE5.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GE5.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GE5.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GE5.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GE6.Description             = 'Ich mache mir Sorgen, dass sich mein Zustand verschlechtern wird';
            subject_info.fields.facit_f_GE6.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GE6.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GE6.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GE6.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GE6.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GF1.Description             = 'Ich bin in der Lage zu arbeiten (einschließlich Arbeit zu Hause)';
            subject_info.fields.facit_f_GF1.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GF1.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GF1.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GF1.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GF1.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GF2.Description             = 'Meine Arbeit (einschließlich Arbeit zu Hause) füllt mich aus';
            subject_info.fields.facit_f_GF2.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GF2.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GF2.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GF2.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GF2.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GF3.Description             = 'Ich kann mein Leben genießen';
            subject_info.fields.facit_f_GF3.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GF3.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GF3.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GF3.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GF3.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GF4.Description             = 'Ich habe mich mit meiner Krankheit abgefunden';
            subject_info.fields.facit_f_GF4.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GF4.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GF4.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GF4.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GF4.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GF5.Description             = 'Ich schlafe gut';
            subject_info.fields.facit_f_GF5.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GF5.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GF5.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GF5.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GF5.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GF6.Description             = 'Ich kann meine Freizeit genießen';
            subject_info.fields.facit_f_GF6.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GF6.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GF6.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GF6.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GF6.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_GF7.Description             = 'Ich bin derzeit mit meinem Leben zufrieden';
            subject_info.fields.facit_f_GF7.Levels.Q1                        = 'Keine Antwort'; 
            subject_info.fields.facit_f_GF7.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_GF7.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_GF7.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_GF7.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_GF7.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_HI7.Description             = 'Ich bin erschöpft';
            subject_info.fields.facit_f_HI7.Levels.A0                       = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_HI7.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_HI7.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_HI7.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_HI7.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_HI12.Description             = 'Ich fühle mich insgesamt schwach';
            subject_info.fields.facit_f_HI12.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_HI12.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_HI12.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_HI12.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_HI12.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An1.Description             = 'Ich fühle mich lustlos (ausgelaugt)';
            subject_info.fields.facit_f_An1.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An1.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An1.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An1.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An1.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An2.Description             = 'Ich bin müde';
            subject_info.fields.facit_f_An2.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An2.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An2.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An2.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An2.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An3.Description             = 'Es fällt mir schwer, etwas anzufangen, weil ich müde bin';
            subject_info.fields.facit_f_An3.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An3.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An3.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An3.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An3.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An4.Description             = 'Es fällt mir schwer, etwas zu Ende zu führen, weil ich müde bin';
            subject_info.fields.facit_f_An4.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An4.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An4.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An4.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An4.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An5.Description             = 'Ich habe Energie';
            subject_info.fields.facit_f_An5.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An5.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An5.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An5.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An5.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An7.Description             = 'Ich bin in der Lage, meinen gewohnten Aktivitäten nachzugehen (Beruf, Einkaufen, Schule, Freizeit, Sport usw.)';
            subject_info.fields.facit_f_An7.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An7.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An7.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An7.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An7.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An8.Description             = 'Ich habe das Bedürfnis, tagsüber zu schlafen';
            subject_info.fields.facit_f_An8.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An8.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An8.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An8.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An8.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An12.Description             = 'Ich bin zu müde, um zu essen';
            subject_info.fields.facit_f_An12.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An12.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An12.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An12.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An12.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An14.Description             = 'Ich brauche Hilfe bei meinen gewohnten Aktivitäten (Beruf, Einkaufen, Schule, Freizeit, Sport usw.)';
            subject_info.fields.facit_f_An14.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An14.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An14.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An14.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An14.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An15.Description             = 'Ich bin frustriert, weil ich zu müde bin, die Dinge zu tun, die ich machen möchte';
            subject_info.fields.facit_f_An15.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An15.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An15.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An15.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An15.Levels.A4                        = 'Sehr';
            subject_info.fields.facit_f_An16.Description             = 'Ich muss meine sozialen Aktivitäten einschränken, weil ich müde bin';
            subject_info.fields.facit_f_An16.Levels.A0                        = 'Überhaupt nicht'; 
            subject_info.fields.facit_f_An16.Levels.A1                        = 'Ein wenig';
            subject_info.fields.facit_f_An16.Levels.A2                        = 'Mäßig';
            subject_info.fields.facit_f_An16.Levels.A3                        = 'Ziemlich';
            subject_info.fields.facit_f_An16.Levels.A4                        = 'Sehr';
            
            subject_info.fields.hads_a_total_score.Description      = 'sum of points in the HADS-A questions. Higher scores mean more anxiety symptoms';
            subject_info.fields.hads_d_total_score.Description      = 'sum of points in the HADS-D questions. Higher scores mean more depression symptoms';
            subject_info.fields.hads_d_1.Description             = 'Ich fühle mich angespannt und überreizt';
            subject_info.fields.hads_d_1.Levels.A1                        = 'meistens';
            subject_info.fields.hads_d_1.Levels.A2                        = 'oft';
            subject_info.fields.hads_d_1.Levels.A3                        = 'von Zeit zu Zeit/gelegentlich';
            subject_info.fields.hads_d_1.Levels.A4                        = 'überhaupt nicht';
            subject_info.fields.hads_d_2.Description             = 'Ich kann mich heute noch so freuen wie früher';
            subject_info.fields.hads_d_2.Levels.A1                        = 'ganz genau so';
            subject_info.fields.hads_d_2.Levels.A2                        = 'nicht ganz so sehr';
            subject_info.fields.hads_d_2.Levels.A3                        = 'nur noch ein wenig';
            subject_info.fields.hads_d_2.Levels.A4                        = 'kaum oder gar nicht';
            subject_info.fields.hads_d_3.Description             = 'Mich überkommt eine ängstliche Vorahnung, daß etwas Schreckliches passieren könnte';
            subject_info.fields.hads_d_3.Levels.A1                        = 'ja, sehr stark';
            subject_info.fields.hads_d_3.Levels.A2                        = 'ja, aber nicht allzu stark';
            subject_info.fields.hads_d_3.Levels.A3                        = 'etwas, aber es macht mir keine Sorgen';
            subject_info.fields.hads_d_3.Levels.A4                        = 'überhaupt nicht';
            subject_info.fields.hads_d_4.Description             = 'Ich kann lachen und die lustigen Dinge sehen';
            subject_info.fields.hads_d_4.Levels.A1                        = 'ja, so viel wie immer';
            subject_info.fields.hads_d_4.Levels.A2                        = 'nicht mehr ganz so viel';
            subject_info.fields.hads_d_4.Levels.A3                        = 'inzwischen viel weniger';
            subject_info.fields.hads_d_4.Levels.A4                        = 'überhaupt nicht';
            subject_info.fields.hads_d_5.Description             = 'Mir gehen beunruhigende Gedanken durch den Kopf';
            subject_info.fields.hads_d_5.Levels.A1                        = 'einen Großteil der Zeit';
            subject_info.fields.hads_d_5.Levels.A2                        = 'verhältnismäßig oft';
            subject_info.fields.hads_d_5.Levels.A3                        = 'von Zeit zu Zeit, aber nicht allzu oft';
            subject_info.fields.hads_d_5.Levels.A4                        = 'nur gelegentlich/nie';
            subject_info.fields.hads_d_6.Description             = 'Ich fühle mich glücklich';
            subject_info.fields.hads_d_6.Levels.A1                        = 'überhaupt nicht';
            subject_info.fields.hads_d_6.Levels.A2                        = 'selten';
            subject_info.fields.hads_d_6.Levels.A3                        = 'manchmal';
            subject_info.fields.hads_d_6.Levels.A4                        = 'meistens';
            subject_info.fields.hads_d_7.Description             = 'Ich kann behaglich dasitzen und mich entspannen';
            subject_info.fields.hads_d_7.Levels.A1                        = 'ja, natürlich';
            subject_info.fields.hads_d_7.Levels.A2                        = 'gewöhnlich schon';
            subject_info.fields.hads_d_7.Levels.A3                        = 'nicht oft';
            subject_info.fields.hads_d_7.Levels.A4                        = 'überhaupt nicht';
            subject_info.fields.hads_d_8.Description             = 'Ich fühle mich in meinen Aktivitäten gebremst';
            subject_info.fields.hads_d_8.Levels.A1                        = 'fast immer';
            subject_info.fields.hads_d_8.Levels.A2                        = 'sehr oft';
            subject_info.fields.hads_d_8.Levels.A3                        = 'manchmal';
            subject_info.fields.hads_d_8.Levels.A4                        = 'überhaupt nicht';
            subject_info.fields.hads_d_9.Description             = 'Ich fühle mich in meinen Aktivitäten gebremst';
            subject_info.fields.hads_d_9.Levels.A1                        = 'überhaupt nicht';
            subject_info.fields.hads_d_9.Levels.A2                        = 'gelegentlich';
            subject_info.fields.hads_d_9.Levels.A3                        = 'ziemlich oft';
            subject_info.fields.hads_d_9.Levels.A4                        = 'sehr oft';
            subject_info.fields.hads_d_10.Description             = 'Ich habe das Interesse an meiner äußeren Erscheinung verloren';
            subject_info.fields.hads_d_10.Levels.A1                        = 'ja, stimmt genau';
            subject_info.fields.hads_d_10.Levels.A2                        = 'ich kümmere mich nicht so sehr darum, wie ich sollte';
            subject_info.fields.hads_d_10.Levels.A3                        = 'möglicherweise kümmere ich mich zu wenig darum';
            subject_info.fields.hads_d_10.Levels.A4                        = 'ich kümmere mich so viel darum wie immer';
            subject_info.fields.hads_d_11.Description             = 'Ich fühle mich rastlos, muß immer in Bewegung sein';
            subject_info.fields.hads_d_11.Levels.A1                        = 'ja, tatsächlich sehr';
            subject_info.fields.hads_d_11.Levels.A2                        = 'ziemlich';
            subject_info.fields.hads_d_11.Levels.A3                        = 'nicht sehr';
            subject_info.fields.hads_d_11.Levels.A4                        = 'überhaupt nicht';
            subject_info.fields.hads_d_12.Description             = 'Ich blicke mit Freude in die Zukunft';
            subject_info.fields.hads_d_12.Levels.A1                        = 'ja, sehr';
            subject_info.fields.hads_d_12.Levels.A2                        = 'eher weniger als früher';
            subject_info.fields.hads_d_12.Levels.A3                        = 'viel weniger als früher';
            subject_info.fields.hads_d_12.Levels.A4                        = 'kaum bis gar nicht';
            subject_info.fields.hads_d_13.Description             = 'Mich überkommt plötzlich ein panikartiger Zustand';
            subject_info.fields.hads_d_13.Levels.A1                        = 'ja, tatsächlich sehr oft';
            subject_info.fields.hads_d_13.Levels.A2                        = 'ziemlich oft';
            subject_info.fields.hads_d_13.Levels.A3                        = 'nicht sehr oft';
            subject_info.fields.hads_d_13.Levels.A4                        = 'überhaupt nicht';
            subject_info.fields.hads_d_14.Description             = 'Ich kann mich an einem guten Buch, einer Radio- oder Fernsehsendung freuen';
            subject_info.fields.hads_d_14.Levels.A1                        = 'oft';
            subject_info.fields.hads_d_14.Levels.A2                        = 'manchmal';
            subject_info.fields.hads_d_14.Levels.A3                        = 'eher selten';
            subject_info.fields.hads_d_14.Levels.A4                        = 'sehr selten';
            
            subject_info.fields.psqi_K1.Description        = 'component 1: subjective sleeping quality (question 6)';
            subject_info.fields.psqi_K2.Description        = 'component 2: sleeping latency (sum of question 2 and 5a)';
            subject_info.fields.psqi_K3.Description        = 'component 3: sleeping duration (question 4)';
            subject_info.fields.psqi_K4.Description        = 'component 4: sleeping efficiancy (sleeping duration divided by duration in bed)';
            subject_info.fields.psqi_K5.Description        = 'component 5: sleeping disturbances (5b -5j)';
            subject_info.fields.psqi_K6.Description        = 'component 6: consumption of sleeping pills (question 7)';
            subject_info.fields.psqi_K7.Description        = 'component 8: daytime sleepiness (sum of question 8 and 9)';
            subject_info.fields.psqi_total_score.Description        = 'sum of points in the PSQI questionnaire. Higher scores mean more sleep disorder symptoms';            
            subject_info.fields.psqi_1.Description             = 'Wann sind Sie während der letzten vier Wochen gewöhnlich abends zu Bett gegangen?';    
            subject_info.fields.psqi_1.Unit                         = 'time of day';
            subject_info.fields.psqi_2.Description             = 'Wie lange hat es während der letzten vier Wochen gewöhnlich gedauert, bis Sie nachts eingeschlafen sind?';    
            subject_info.fields.psqi_2.Unit                         = 'minutes';
            subject_info.fields.psqi_3.Description             = 'Wann sind Sie während der letzten vier Wochen gewöhnlich morgens aufgestanden?';    
            subject_info.fields.psqi_3.Unit                         = 'time of day';
            subject_info.fields.psqi_4.Description             = 'Wieviele Stunden haben Sie während der letzten vier Wochen pro Nacht tatsächlich geschlafen? (Das muß nicht mit der Anzahl der Stunden, die Sie im Bett verbracht haben, übereinstimmen.)';    
            subject_info.fields.psqi_4.Unit                         = 'hours';
            subject_info.fields.psqi_5a.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie nicht innerhalb von 30 Minuten einschlafen konnten?';
            subject_info.fields.psqi_5a.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5a.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5a.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5a.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5b.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie mitten in der Nacht oder früh morgens aufgewacht sind?';
            subject_info.fields.psqi_5b.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5b.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5b.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5b.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5c.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie aufstehen mußten, um zur Toilette zu gehen?';
            subject_info.fields.psqi_5c.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5c.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5c.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5c.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5d.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie Beschwerden beim Atmen hatten?';
            subject_info.fields.psqi_5d.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5d.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5d.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5d.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5e.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie husten mußten oder laut geschnarcht haben?';
            subject_info.fields.psqi_5e.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5e.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5e.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5e.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5f.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Ihnen zu kalt war?';
            subject_info.fields.psqi_5f.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5f.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5f.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5f.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5g.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Ihnen zu warm war?';
            subject_info.fields.psqi_5g.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5g.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5g.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5g.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5h.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie schlecht geträumt hatten?';
            subject_info.fields.psqi_5h.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5h.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5h.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5h.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5i.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, weil Sie Schmerzen hatten?';
            subject_info.fields.psqi_5i.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5i.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5i.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5i.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_5j1.Description             = 'Aus welchen anderen Gründen haben Sie während der letzten vier Wochen schlecht geschlafen';
            subject_info.fields.psqi_5j2.Description             = 'Wie oft haben Sie während der letzten vier Wochen schlecht geschlafen, aus anderen Gründen?';
            subject_info.fields.psqi_5j2.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_5j2.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_5j2.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_5j2.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_6.Description             = 'Wie würden Sie insgesamt die Qualität Ihres Schlafes während der letzten vier Wochen beurteilen?';
            subject_info.fields.psqi_6.Levels.A1                        = 'Sehr gut';
            subject_info.fields.psqi_6.Levels.A2                        = 'Ziemlich gut';
            subject_info.fields.psqi_6.Levels.A3                        = 'Ziemlich schlecht';
            subject_info.fields.psqi_6.Levels.A4                        = 'Sehr schlecht';
            subject_info.fields.psqi_7.Description             = 'Wie oft haben Sie während der letzten vier Wochen Schlafmittel eingenommen (vom Arzt verschriebene oder frei verkäufliche)?';
            subject_info.fields.psqi_7.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_7.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_7.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_7.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_8.Description             = 'Wie oft hatten Sie während der letzten vier Wochen Schwierigkeiten wachzubleiben, etwa beim Autofahren, beim Essen oder bei gesellschaftlichen Anlässen?';
            subject_info.fields.psqi_8.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_8.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_8.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_8.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_9.Description             = 'Hatten Sie während der letzten vier Wochen Probleme, mit genügend Schwung die üblichen Alltagsaufgaben zu erledigen?';
            subject_info.fields.psqi_9.Levels.A1                        = 'Keine Probleme';
            subject_info.fields.psqi_9.Levels.A2                        = 'Kaum Probleme';
            subject_info.fields.psqi_9.Levels.A3                        = 'Etwas Probleme';
            subject_info.fields.psqi_9.Levels.A4                        = 'Große Probleme';
            subject_info.fields.psqi_10.Description             = 'Schlafen Sie allein in Ihrem Zimmer?';
            subject_info.fields.psqi_10.Levels.A1                        = 'ja';
            subject_info.fields.psqi_10.Levels.A2                        = 'Ja, aber ein Partner/Mitbewohner schläft in einem anderen Zimmer';
            subject_info.fields.psqi_10.Levels.A3                        = 'Nein, der Partner schläft im selben Zimmer, aber nicht im selben Bett';
            subject_info.fields.psqi_10.Levels.A4                        = 'Nein, der Partner schläft im selben Bett';
            subject_info.fields.psqi_10a.Description             = 'Falls Sie einen Mitbewohner / Partner haben, fragen Sie sie/ihn bitte, ob und wie oft er/sie bei Ihnen folgendes bemerkt hat. Lautes Schnarchen';
            subject_info.fields.psqi_10a.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_10a.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_10a.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_10a.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_10b.Description             = 'Falls Sie einen Mitbewohner / Partner haben, fragen Sie sie/ihn bitte, ob und wie oft er/sie bei Ihnen folgendes bemerkt hat. Lange Atempausen während des Schlafes';
            subject_info.fields.psqi_10b.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_10b.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_10b.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_10b.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_10c.Description             = 'Falls Sie einen Mitbewohner / Partner haben, fragen Sie sie/ihn bitte, ob und wie oft er/sie bei Ihnen folgendes bemerkt hat. Zucken oder ruckartige Bewegungen der Beine während des Schlafes';
            subject_info.fields.psqi_10c.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_10c.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_10c.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_10c.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_10d.Description             = 'Falls Sie einen Mitbewohner / Partner haben, fragen Sie sie/ihn bitte, ob und wie oft er/sie bei Ihnen folgendes bemerkt hat. Nächtliche Phasen von Verwirrung oder Desorientierung während des Schlafes';
            subject_info.fields.psqi_10d.Levels.A1                        = 'Während der letzten vier Wochen gar nicht';
            subject_info.fields.psqi_10d.Levels.A2                        = 'Weniger als einmal pro Woche';
            subject_info.fields.psqi_10d.Levels.A3                        = 'Einmal oder zweimal pro Woche';
            subject_info.fields.psqi_10d.Levels.A4                        = 'Dreimal oder häufiger pro Woche';
            subject_info.fields.psqi_10e.Description             = 'Falls Sie einen Mitbewohner / Partner haben, fragen Sie sie/ihn bitte, ob und wie oft er/sie bei Ihnen folgendes bemerkt hat. Oder andere Formen von Unruhe während des Schlafes';

            subject_info.fields.oddball_reaction_time.Description   = 'average time between stimulus Onset and button press at target stimuli of the oddball task';
            subject_info.fields.oddball_reaction_time.Unit          = 'seconds';
            subject_info.fields.oddball_miss.Description            = 'number of times that the participant did not react to a target before the next stimulus started after 1.5 seconds in the oddball task';
            subject_info.fields.oddball_false_alarm.Description     = 'number of times that the participant pressed the button even though the current stimulus was not a target in the oddball task';
            
            subject_info.fields.rte_reaction_time_A.Description     = 'average time between stimulus Onset and button press at auditive stimuli of the redundant target effect';
            subject_info.fields.rte_reaction_time_A.Unit            = 'seconds';
            subject_info.fields.rte_reaction_time_V.Description     = 'average time between stimulus Onset and button press at visual stimuli of the redundant target effect';
            subject_info.fields.rte_reaction_time_V.Unit            = 'seconds';            
            subject_info.fields.rte_reaction_time_AV.Description    = 'average time between stimulus Onset and button press at audiovisual stimuli of the redundant target effect';
            subject_info.fields.rte_reaction_time_AV.Unit           = 'seconds';
            subject_info.fields.rte_miss.Description                = 'number of times that the participant did not react to a stimulus before the next stimulus started';
            
            subject_info.fields.pvt_reaction_time.Description       = 'average time between stimulus Onset and button press in the psychomotor vigilance test';
            subject_info.fields.pvt_reaction_time.Unit              = 'seconds';

            subject_info.fields.nback_reaction_time_1.Description   = 'average time between stimulus Onset and button press at target stimuli of the 1-back task';
            subject_info.fields.nback_reaction_time_1.Unit          = 'seconds';
            subject_info.fields.nback_miss_1.Description            = 'number of times that the participant did not react to a target before the next stimulus started in the 1-back task';
            subject_info.fields.nback_false_alarm_1.Description     = 'number of times that the participant pressed the button even though the current stimulus was not a target in the 1-back task';

            subject_info.fields.nback_reaction_time_2.Description   = 'average time between stimulus Onset and button press at target stimuli of the 2-back task';
            subject_info.fields.nback_reaction_time_2.Unit          = 'seconds';
            subject_info.fields.nback_miss_2.Description            = 'number of times that the participant did not react to a target before the next stimulus started in the 2-back task';
            subject_info.fields.nback_false_alarm_2.Description     = 'number of times that the participant pressed the button even though the current stimulus was not a target in the 2-back task';
            
            subject_info.fields.time_of_day.Description             = 'Time at which the examination took place';
            subject_info.fields.time_of_day.Unit                    = 'time of day'

            subject_info.fields.comments.Description                = 'Anything that differed from the usual process can be noted here';

            subject_info.cols = {'participant_id', 'nr', 'age', 'sex', 'group', 'eyesight', 'graduation', 'years_of_education', 'neurological_diseases_1', 'neurological_diseases_2', 'other_diseases', 'tmt_a_time', 'tmt_b_time', 'tmt_a_mistakes', 'tmt_b_mistakes', 'facit_f_PWB', 'facit_f_SWB', 'facit_f_EWB', 'facit_f_FWB', 'facit_f_FS', 'facit_f_TOI', 'fact_g_total_score', 'facit_f_total_score', 'facit_f_GP1', 'facit_f_GP2', 'facit_f_GP3', 'facit_f_GP4', 'facit_f_GP5', 'facit_f_GP6', 'facit_f_GP7', 'facit_f_GS1', 'facit_f_GS2', 'facit_f_GS3', 'facit_f_GS4', 'facit_f_GS5', 'facit_f_GS6', 'facit_f_GS7', 'facit_f_GE1', 'facit_f_GE2', 'facit_f_GE3', 'facit_f_GE4', 'facit_f_GE5', 'facit_f_GE6', 'facit_f_GF1', 'facit_f_GF2', 'facit_f_GF3', 'facit_f_GF4', 'facit_f_GF5', 'facit_f_GF6', 'facit_f_GF7', 'facit_f_HI7', 'facit_f_HI12', 'facit_f_An1', 'facit_f_An2', 'facit_f_An3', 'facit_f_An4', 'facit_f_An5', 'facit_f_An7', 'facit_f_An8', 'facit_f_An12', 'facit_f_An14', 'facit_f_An15', 'facit_f_An16', 'hads_a_total_score', 'hads_d_total_score', 'hads_d_1', 'hads_d_2', 'hads_d_3', 'hads_d_4', 'hads_d_5', 'hads_d_6', 'hads_d_7', 'hads_d_8', 'hads_d_9', 'hads_d_10', 'hads_d_11', 'hads_d_12', 'hads_d_13', 'hads_d_14', 'psqi_K1', 'psqi_K2', 'psqi_K3', 'psqi_K4', 'psqi_K5', 'psqi_K6', 'psqi_K7', 'psqi_total_score', 'psqi_1', 'psqi_2', 'psqi_3', 'psqi_4', 'psqi_5a', 'psqi_5b', 'psqi_5c', 'psqi_5d', 'psqi_5e', 'psqi_5f', 'psqi_5g', 'psqi_5h', 'psqi_5i','psqi_5j1', 'psqi_5j2', 'psqi_6', 'psqi_7', 'psqi_8', 'psqi_9', 'psqi_10', 'psqi_10a', 'psqi_10b', 'psqi_10c', 'psqi_10d', 'psqi_10e', 'oddball_reaction_time', 'oddball_miss', 'oddball_false_alarm', 'rte_reaction_time_A', 'rte_reaction_time_V', 'rte_reaction_time_AV', 'rte_miss', 'pvt_reaction_time', 'nback_reaction_time_1', 'nback_miss_1', 'nback_false_alarm_1', 'nback_reaction_time_2', 'nback_miss_2', 'nback_false_alarm_2', 'time_of_day', 'comments' };
            subject_info.data = {pp.participant_id(p,:), p, age, sex, group, eyesight, graduation, years, neurological_1, neurological_2, other, tmt_a_time, tmt_b_time, tmt_a_mistakes, tmt_b_mistakes, facitf_pwb, facitf_swb, facitf_ewb, facitf_fwb, facitf_fs, facitf_toi, factg_ts, facitf_ts, facitf_GP1, facitf_GP2, facitf_GP3, facitf_GP4, facitf_GP5, facitf_GP6, facitf_GP7, facitf_GS1, facitf_GS2, facitf_GS3, facitf_GS4, facitf_GS5, facitf_GS6, facitf_GS7, facitf_GE1, facitf_GE2, facitf_GE3, facitf_GE4, facitf_GE5, facitf_GE6, facitf_GF1, facitf_GF2, facitf_GF3, facitf_GF4, facitf_GF5, facitf_GF6, facitf_GF7, facitf_HI7, facitf_HI12, facitf_An1, facitf_An2, facitf_An3, facitf_An4, facitf_An5, facitf_An7, facitf_An8, facitf_An12, facitf_An14, facitf_An15, facitf_An16, hadsa_ts, hadsd_ts, hadsd_1, hadsd_2, hadsd_3, hadsd_4, hadsd_5, hadsd_6, hadsd_7, hadsd_8, hadsd_9, hadsd_10, hadsd_11, hadsd_12, hadsd_13, hadsd_14, psqi_K1, psqi_K2, psqi_K3, psqi_K4, psqi_K5, psqi_K6, psqi_K7, psqi_ts, psqi_1, psqi_2, psqi_3, psqi_4, psqi_5a, psqi_5b, psqi_5c, psqi_5d, psqi_5e, psqi_5f, psqi_5g, psqi_5h, psqi_5i, psqi_5j1, psqi_5j2, psqi_6, psqi_7, psqi_8, psqi_9, psqi_10, psqi_10a, psqi_10b, psqi_10c, psqi_10d, psqi_10e, oddball_rt{p}, oddball_miss{p}, oddball_false_alarm{p}, rte_rt_A{p}, rte_rt_V{p}, rte_rt_AV{p}, rte_miss{p}, pvt_rt{p}, nback_rt_1{p}, nback_miss_1{p}, nback_false_alarm_1{p}, nback_rt_2{p}, nback_miss_2{p}, nback_false_alarm_2{p}, pp.time_of_day(p,:), pp.comments(p,:)};
            %------------------------------------------------------------------
            
            bemobil_xdf2bids(config, 'eeg_metadata', eeg_info, 'participant_metadata', subject_info);

        end
    end
end

%% rename folders and files

cd(fileparts(fileparts(PATHIN)))
vp = dir;
vp = vp([vp(:).isdir]);
vp(1:4) = [];

for f = 1:length(vp)
    cd(fileparts(fileparts(PATHIN)))
    old_folder_name = vp(f).name;
    new_folder_name = pp.participant_id(f,:);
    movefile(old_folder_name, new_folder_name);

    cd(pp.participant_id(f,:))
    cur = [];
    cur = dir;
    fol = cur(3).name;
    cur(1:3) = [];
    new_name1 = [pp.participant_id(f,:) extractAfter(cur.name, length(vp(f).name))];
    movefile(cur.name, new_name1);

    cd('eeg')
    cur = dir;
    cur(1:2) = [];
    for v = 1:length(cur)
        new_name2 = [pp.participant_id(f,:) extractAfter(cur(v).name, length(vp(f).name))];
        movefile(cur(v).name, new_name2);
    end

    cur = dir('*.vhdr');
    cd(fileparts(pwd))
    scans = tdfread(new_name1);
    left = cellstr(scans.filename); 
    right = cellstr(scans.acq_time);
    head = fieldnames(scans);
    head(1,2) = head(2,1);
    head(2,:) = [];
    c = [head;left,right];

    for s = 1:length(cur)
        new_name3 = cellstr(['eeg/' cur(s).name]);
        c(s+1,1) = new_name3;
    end
        
    writecell(c,new_name1, 'filetype','text', 'delimiter','\t')
    


end
