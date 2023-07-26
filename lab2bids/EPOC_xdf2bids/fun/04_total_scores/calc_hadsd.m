function hadsd_ts = calc_hadsd(hadsd_2,hadsd_4,hadsd_6,hadsd_8,hadsd_10,hadsd_12,hadsd_14)
    hadsd_2 = str2num(extractAfter(hadsd_2,1));
    hadsd_4 = str2num(extractAfter(hadsd_4,1));
    hadsd_6 = str2num(extractAfter(hadsd_6,1));
    hadsd_8 = str2num(extractAfter(hadsd_8,1));
    hadsd_10 = str2num(extractAfter(hadsd_10,1));
    hadsd_12 = str2num(extractAfter(hadsd_12,1));
    hadsd_14 = str2num(extractAfter(hadsd_14,1));
    hadsd_ts = (hadsd_2-1)+(hadsd_4-1)+(4-hadsd_6)+(4-hadsd_8)+(4-hadsd_10)+(hadsd_12-1)+(hadsd_14-1);
end