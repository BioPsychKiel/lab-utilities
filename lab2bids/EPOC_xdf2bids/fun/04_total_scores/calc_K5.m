function psqi_K5 = calc_K5(psqi_5b, psqi_5c, psqi_5d, psqi_5e, psqi_5f, psqi_5g, psqi_5h, psqi_5i, psqi_5j2)
    
    s = (str2num(extractAfter(psqi_5b,1))-1) + (str2num(extractAfter(psqi_5c,1))-1) + (str2num(extractAfter(psqi_5d,1))-1) + (str2num(extractAfter(psqi_5e,1))-1) + (str2num(extractAfter(psqi_5f,1))-1) + (str2num(extractAfter(psqi_5g,1))-1) + (str2num(extractAfter(psqi_5h,1))-1) + (str2num(extractAfter(psqi_5i,1))-1) + (str2num(extractAfter(psqi_5j2,1))-1);

    if s == 0
        psqi_K5 = 0;
    elseif s > 0 & s <= 9
        psqi_K5 = 1;
    elseif s > 9 & s <= 18
        psqi_K5 = 2;
    elseif s > 18 & s <= 27
        psqi_K5 = 3;
    end


end