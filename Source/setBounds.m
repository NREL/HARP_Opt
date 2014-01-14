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

function [OPT] = setBounds(TURB,BLADE,OPT)

% determine the number of aerodynamic variables, define bounds (OPT.lb, OPT.ub) & linear contraints (Ax <= b)
switch TURB.CONTROL
    case {'FSFP','FSVP_S','FSVP_F'}
        if BLADE.NUM_FOILS == 1
            OPT.numVars = 2*BLADE.NUM_CP + 1;
            OPT.lb      = [BLADE.TWIST_LB BLADE.CHORD_LB TURB.RPM_MIN]';
            OPT.ub      = [BLADE.TWIST_UB BLADE.CHORD_UB TURB.RPM_MAX]';
        else
            OPT.numVars = 2*BLADE.NUM_CP + BLADE.NUM_FOILS + 1;
            OPT.lb      = [BLADE.TWIST_LB BLADE.CHORD_LB BLADE.FOIL_LB_DIM TURB.RPM_MIN]';
            OPT.ub      = [BLADE.TWIST_UB BLADE.CHORD_UB BLADE.FOIL_UB_DIM TURB.RPM_MAX]';
        end
        
    case {'VSFP','VSVP_S','VSVP_F'}
        if BLADE.NUM_FOILS == 1
            OPT.numVars = 2*BLADE.NUM_CP;
            OPT.lb      = [BLADE.TWIST_LB BLADE.CHORD_LB TURB.TSR_MIN]';
            OPT.ub      = [BLADE.TWIST_UB BLADE.CHORD_UB TURB.TSR_MAX]';            
        else
            OPT.numVars = 2*BLADE.NUM_CP + BLADE.NUM_FOILS;
            OPT.lb      = [BLADE.TWIST_LB BLADE.CHORD_LB BLADE.FOIL_LB_DIM TURB.TSR_MIN]';
            OPT.ub      = [BLADE.TWIST_UB BLADE.CHORD_UB BLADE.FOIL_UB_DIM TURB.TSR_MAX]';
        end
        
end

% constraints which impose monotonically decreasing twist & chord
OPT.Atc = zeros(BLADE.NUM_CP-1, BLADE.NUM_CP);
for i = 1:BLADE.NUM_CP-1
    OPT.Atc(i, i)   = -1;
    OPT.Atc(i, i+1) = 1;
end

% constraints which impose monotonically increasing radial location of airfoils
if BLADE.NUM_FOILS > 1
    Af = zeros(BLADE.NUM_FOILS-1, BLADE.NUM_FOILS);
    for i = 1:BLADE.NUM_FOILS-1
        Af(i, i)   = 1;
        Af(i, i+1) = -1;
    end
else
    Af = [];
end

% create matrices for linear inequality constraints: Ax <= b
if BLADE.DEC_TWIST
    OPT.Aineq = blkdiag(OPT.Atc, OPT.Atc, Af);
else
    OPT.Aineq = blkdiag(zeros(0,BLADE.NUM_CP), OPT.Atc, Af);
end
OPT.Aineq = blkdiag(OPT.Aineq, zeros(0,1));  % append another row and column for the additional rotor speed/TSR design variable
OPT.bineq = zeros(size(OPT.Aineq,1), 1);

OPT.Aeq = [];
OPT.beq = [];
OPT.nonlcon = [];
