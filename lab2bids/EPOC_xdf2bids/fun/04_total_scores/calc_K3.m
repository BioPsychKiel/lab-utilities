function psqi_K3 = calc_K3(psqi_4)
    if psqi_4 >= 7
        psqi_K3 = 0;
    elseif psqi_4 < 7 & psqi_4 >= 6
        psqi_K3 = 1;
    elseif psqi_4 < 6 & psqi_4 >= 5
        psqi_K3 = 2;
    elseif psqi_4 > 5
        psqi_K3 = 3;
    end
end