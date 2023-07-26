function facitf_pwb = calc_pwb(facitf_GP1,facitf_GP2,facitf_GP3,facitf_GP4,facitf_GP5,facitf_GP6,facitf_GP7)
    facitf_GP1 = str2num(extractAfter(facitf_GP1,1));
    facitf_GP2 = str2num(extractAfter(facitf_GP2,1));
    facitf_GP3 = str2num(extractAfter(facitf_GP3,1));
    facitf_GP4 = str2num(extractAfter(facitf_GP4,1));
    facitf_GP5 = str2num(extractAfter(facitf_GP5,1));
    facitf_GP6 = str2num(extractAfter(facitf_GP6,1));
    facitf_GP7 = str2num(extractAfter(facitf_GP7,1));
    facitf_pwb = (4-facitf_GP1)+(4-facitf_GP2)+(4-facitf_GP3)+(4-facitf_GP4)+(4-facitf_GP5)+(4-facitf_GP6)+(4-facitf_GP7);
end