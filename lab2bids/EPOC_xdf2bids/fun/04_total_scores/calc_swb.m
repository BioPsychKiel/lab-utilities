function facitf_swb = calc_swb(facitf_GS1,facitf_GS2,facitf_GS3,facitf_GS4,facitf_GS5,facitf_GS6,facitf_GS7)
    facitf_GS1 = str2num(extractAfter(facitf_GS1,1));
    facitf_GS2 = str2num(extractAfter(facitf_GS2,1));
    facitf_GS3 = str2num(extractAfter(facitf_GS3,1));
    facitf_GS4 = str2num(extractAfter(facitf_GS4,1));
    facitf_GS5 = str2num(extractAfter(facitf_GS5,1));
    facitf_GS6 = str2num(extractAfter(facitf_GS6,1));
    facitf_GS7 = str2num(extractAfter(facitf_GS7,1));
    facitf_swb = (facitf_GS1)+(facitf_GS2)+(facitf_GS3)+(facitf_GS4)+(facitf_GS5)+(facitf_GS6)+(facitf_GS7);
end