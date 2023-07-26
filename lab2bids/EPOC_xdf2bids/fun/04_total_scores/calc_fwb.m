function facitf_fwb = calc_fwb(facitf_GF1,facitf_GF2,facitf_GF3,facitf_GF4,facitf_GF5,facitf_GF6,facitf_GF7)
    facitf_GF1 = str2num(extractAfter(facitf_GF1,1));
    facitf_GF2 = str2num(extractAfter(facitf_GF2,1));
    facitf_GF3 = str2num(extractAfter(facitf_GF3,1));
    facitf_GF4 = str2num(extractAfter(facitf_GF4,1));
    facitf_GF5 = str2num(extractAfter(facitf_GF5,1));
    facitf_GF6 = str2num(extractAfter(facitf_GF6,1));
    facitf_GF7 = str2num(extractAfter(facitf_GF7,1));
    facitf_fwb = (facitf_GF1)+(facitf_GF2)+(facitf_GF3)+(facitf_GF4)+(facitf_GF5)+(facitf_GF6)+(facitf_GF7);
end