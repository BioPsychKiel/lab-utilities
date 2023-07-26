function hadsa_ts = calc_hadsa(hadsd_1,hadsd_3,hadsd_5,hadsd_7,hadsd_9,hadsd_11,hadsd_13)
    hadsd_1 = str2num(extractAfter(hadsd_1,1));
    hadsd_3 = str2num(extractAfter(hadsd_3,1));
    hadsd_5 = str2num(extractAfter(hadsd_5,1));
    hadsd_7 = str2num(extractAfter(hadsd_7,1));
    hadsd_9 = str2num(extractAfter(hadsd_9,1));
    hadsd_11 = str2num(extractAfter(hadsd_11,1));
    hadsd_13 = str2num(extractAfter(hadsd_13,1));
    hadsa_ts = (4-hadsd_1)+(4-hadsd_3)+(4-hadsd_5)+(hadsd_7-1)+(hadsd_9-1)+(4-hadsd_11)+(4-hadsd_13);
end