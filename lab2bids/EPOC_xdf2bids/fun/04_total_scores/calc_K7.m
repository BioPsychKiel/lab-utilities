function psqi_K7 = calc_K7(psqi_8, psqi_9)
    
    s = (str2num(extractAfter(psqi_8,1))-1) + (str2num(extractAfter(psqi_9,1))-1);

    if s == 0
        psqi_K7 = 0;
    elseif s > 0 & s <= 2
        psqi_K7 = 1;
    elseif s > 2 & s <= 4
        psqi_K7 = 2;
    elseif s > 4 & s <= 6
        psqi_K7 = 3;
    end

end