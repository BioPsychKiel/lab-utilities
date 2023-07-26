function facitf_fs = calc_fs(facitf_HI7,facitf_HI12,facitf_An1,facitf_An2,facitf_An3,facitf_An4,facitf_An5,facitf_An7,facitf_An8,facitf_An12,facitf_An14,facitf_An15,facitf_An16)
    facitf_HI7 = str2num(extractAfter(facitf_HI7,1));
    facitf_HI12 = str2num(extractAfter(facitf_HI12,1));
    facitf_An1 = str2num(extractAfter(facitf_An1,1));
    facitf_An2 = str2num(extractAfter(facitf_An2,1));
    facitf_An3 = str2num(extractAfter(facitf_An3,1));
    facitf_An4 = str2num(extractAfter(facitf_An4,1));
    facitf_An5 = str2num(extractAfter(facitf_An5,1));
    facitf_An7 = str2num(extractAfter(facitf_An7,1));
    facitf_An8 = str2num(extractAfter(facitf_An8,1));
    facitf_An12 = str2num(extractAfter(facitf_An12,1));
    facitf_An14 = str2num(extractAfter(facitf_An14,1));
    facitf_An15 = str2num(extractAfter(facitf_An15,1));
    facitf_An16 = str2num(extractAfter(facitf_An16,1));
    facitf_fs = (4-facitf_HI7)+(4-facitf_HI12)+(4-facitf_An1)+(4-facitf_An2)+(4-facitf_An3)+(4-facitf_An4)+(facitf_An5)+(facitf_An7)+(4-facitf_An8)+(4-facitf_An12)+(4-facitf_An14)+(4-facitf_An15)+(4-facitf_An16);
end