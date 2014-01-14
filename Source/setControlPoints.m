%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2014 Danny Sale and Michael Lawson
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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