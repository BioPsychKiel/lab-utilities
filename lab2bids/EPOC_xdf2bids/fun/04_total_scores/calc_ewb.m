function facitf_ewb = calc_ewb(facitf_GE1,facitf_GE2,facitf_GE3,facitf_GE4,facitf_GE5,facitf_GE6)
    facitf_GE1 = str2num(extractAfter(facitf_GE1,1));
    facitf_GE2 = str2num(extractAfter(facitf_GE2,1));
    facitf_GE3 = str2num(extractAfter(facitf_GE3,1));
    facitf_GE4 = str2num(extractAfter(facitf_GE4,1));
    facitf_GE5 = str2num(extractAfter(facitf_GE5,1));
    facitf_GE6 = str2num(extractAfter(facitf_GE6,1));
    facitf_ewb = (4-facitf_GE1)+(facitf_GE2)+(4-facitf_GE3)+(4-facitf_GE4)+(4-facitf_GE5)+(4-facitf_GE6);
end