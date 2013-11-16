function BLADE = setElmSpacing(BLADE,TURB,WTP)
switch BLADE.ELM_SPACING
    case 'equal'
        TURB.DEL_ELM = (TURB.ROTOR_RAD - TURB.HUB_RAD)/WTP.NUM_SEG;
        BLADE.R_ELM   = linspace(TURB.HUB_RAD+TURB.DEL_ELM/2, TURB.ROTOR_RAD-TURB.DEL_ELM/2, WTP.NUM_SEG)';
    case 'cosine'
        elmEnds = cosspace(TURB.HUB_RAD,TURB.ROTOR_RAD,WTP.NUM_SEG+1,'both');
        for n = 1:WTP.NUM_SEG
            BLADE.R_ELM(n,1) = (elmEnds(n+1) + elmEnds(n))/2;
        end
end
BLADE.r_R = BLADE.R_ELM/TURB.ROTOR_RAD;