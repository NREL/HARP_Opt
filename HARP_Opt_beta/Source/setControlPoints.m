function OPT = setControlPoints(BLADE,OPT,TURB)
% This subroutine sets the control points for twist and chord length for 

switch BLADE.ROOT_STYLE
    
    case 'foil'
        OPT.CP_TWIST_X = BLADE.CPS_DIM;
        OPT.CP_CHORD_X = BLADE.CPS_DIM;  
        
    case 'circle'
        rt_cp_start = BLADE.RT_TRAN_ST*TURB.ROTOR_RAD; 
        rt_cps_dim  = BLADE.RT_CPS*TURB.ROTOR_RAD;
        
        OPT.CP_TWIST_X = BLADE.CPS_DIM;
        OPT.CP_CHORD_X = [rt_cp_start rt_cps_dim BLADE.CPS_DIM];
        
end

OPT.CP_FOIL_Y  = (BLADE.FOIL_VALS(BLADE.FOIL_VALS < 100))';