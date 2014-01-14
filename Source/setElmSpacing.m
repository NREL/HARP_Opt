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