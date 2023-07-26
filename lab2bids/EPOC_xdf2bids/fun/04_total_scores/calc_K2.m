function psqi_K2 = calc_K2(psqi_2, psqi_5a)
    if psqi_2 <= 15
        psqi_2 = 0;
    elseif psqi_2 > 15 & psqi_2 <= 30
        psqi_2 = 1;
    elseif psqi_2 > 30 & psqi_2 <= 60
        psqi_2 = 2;
    elseif psqi_2 > 60
        psqi_2 = 3;
    end

    psqi_5a = str2num(extractAfter(psqi_5a,1))-1;

    s = psqi_2 + psqi_5a;
    if s == 0
        psqi_K2 = 0;
    elseif s > 0 & s <= 2
        psqi_K2 = 1;
    elseif s > 2 & s <= 4
        psqi_K2 = 2;
    elseif s > 4 & s <= 6
        psqi_K2 = 3;
    end


end