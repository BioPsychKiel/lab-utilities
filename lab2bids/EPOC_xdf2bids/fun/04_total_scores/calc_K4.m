function psqi_K4 = calc_K4(psqi_1, psqi_3, psqi_4)
    
    psqi_1 = str2num(extractBefore(psqi_1,':')) + (str2num(extractAfter(psqi_1,':')) / 60);
    psqi_3 = str2num(extractBefore(psqi_3,':')) + (str2num(extractAfter(psqi_3,':')) / 60);

    time_in_bed = psqi_3 - psqi_1;
    if time_in_bed < 0 
        time_in_bed = 24+time_in_bed;
    end
    sleep_eff = (psqi_4/time_in_bed)*100;

    if sleep_eff >= 85
        psqi_K4 = 0;
    elseif sleep_eff < 85 & sleep_eff >= 75
        psqi_K4 = 1;
    elseif sleep_eff < 75 & sleep_eff >= 65
        psqi_K4 = 2;
    elseif sleep_eff < 65
        psqi_K4 = 3;
    end


end