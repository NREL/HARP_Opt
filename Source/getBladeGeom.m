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

function [chord twist perThick dimThick cps] = getBladeGeom(x0,OPT,BLADE,TURB)

% make sure x0 is a column vector
x0 = x0(:);

% assign aerodynamic design variables
twist_CP_Y = x0(1:BLADE.NUM_CP);
chord_CP_Y = x0(BLADE.NUM_CP+1:2*BLADE.NUM_CP);

switch BLADE.ROOT_STYLE
    case 'foil'

        twist = interp1Bez(OPT.CP_TWIST_X, twist_CP_Y, BLADE.R_ELM);
        chord = interp1Bez(OPT.CP_CHORD_X, chord_CP_Y, BLADE.R_ELM);
        
        if BLADE.NUM_FOILS > 1
            foil_CP_X  = x0(2*BLADE.NUM_CP+1:2*BLADE.NUM_CP+BLADE.NUM_FOILS);
            perThick   = interp1(foil_CP_X, OPT.CP_FOIL_Y, BLADE.R_ELM);
            perThick(BLADE.R_ELM < foil_CP_X(1))   = OPT.CP_FOIL_Y(1);
            perThick(BLADE.R_ELM > foil_CP_X(end)) = OPT.CP_FOIL_Y(end);
        else
            foil_CP_X = [];
            perThick  = BLADE.FOIL_VALS(1) .* ones(numel(BLADE.R_ELM), 1);
        end
        dimThick = chord.*perThick./100;
        
        % control points
        cps.twist_cp_x = OPT.CP_TWIST_X;
        cps.twist_cp_y = twist_CP_Y;
        cps.chord_cp_x = OPT.CP_CHORD_X;
        cps.chord_cp_y = chord_CP_Y;
        cps.foil_cp_x  = foil_CP_X;
        
    case 'circle'
        
        % compute temporary percent thickness
        if BLADE.NUM_FOILS > 1
            foil_CP_X    = x0(2*BLADE.NUM_CP+1:2*BLADE.NUM_CP+BLADE.NUM_FOILS);
            perThick_tmp = interp1(foil_CP_X, OPT.CP_FOIL_Y, BLADE.R_ELM);
            perThick_tmp(BLADE.R_ELM < foil_CP_X(1))   = OPT.CP_FOIL_Y(1);
            perThick_tmp(BLADE.R_ELM > foil_CP_X(end)) = OPT.CP_FOIL_Y(end);
        else
            foil_CP_X    = BLADE.CPS(1)*TURB.ROTOR_RAD;
            perThick_tmp = BLADE.FOIL_VALS(1) .* ones(numel(BLADE.R_ELM), 1);
        end
        
        
        % compute root chord value which minimizes the curvature of dimensional thickness
        rtChordOpt = optRootChord(BLADE.RT_CHORD_MIN, ...
                                  BLADE.RT_CHORD_MAX, ...
                                  OPT.CP_CHORD_X, ...
                                  chord_CP_Y, ...
                                  OPT.CP_TWIST_X, ...
                                  twist_CP_Y, ...
                                  foil_CP_X, ...
                                  perThick_tmp, ...
                                  BLADE);
                              
       [chord twist perThick dimThick cps] = bladeGeomCircRt(rtChordOpt, ...
                                                             OPT.CP_CHORD_X, ...
                                                             chord_CP_Y, ...
                                                             OPT.CP_TWIST_X, ...
                                                             twist_CP_Y, ...
                                                             foil_CP_X, ...
                                                             perThick_tmp, ...
                                                             BLADE);
end

end % function getBladeGeom

%=======================================

function rtChordOpt = optRootChord(RT_CHORD_MIN, ...
                                   RT_CHORD_MAX, ...
                                   CHORD_CP_X, ...
                                   chord_CP_Y, ...
                                   TWIST_CP_X, ...
                                   twist_CP_Y, ...
                                   foil_CP_X, ...
                                   perThick_tmp, ...
                                   BLADE)

FUN = @(rtChord) bladeCurv(rtChord, ...
                           CHORD_CP_X, ...
                           chord_CP_Y, ...
                           TWIST_CP_X, ...
                           twist_CP_Y, ...
                           foil_CP_X, ...
                           perThick_tmp, ...
                           BLADE);

x_init = (RT_CHORD_MIN + RT_CHORD_MAX)/2;
LB     = RT_CHORD_MIN;
UB     = RT_CHORD_MAX;
options = optimset('Display', 'off', ... % iter-detailed
                   'FunValCheck', 'off', ...
                   'MaxFunEvals', Inf, ...
                   'MaxIter', 100, ...
                   'OutputFcn', [], ...
                   'TolFun', 1e-2, ...
                   'TolX', 1e-2);

[rtChordOpt curvMin exitflag output] = fminsearchbnd(FUN,x_init,LB,UB,options);

end %function optRootChord

%=======================================

function curv = bladeCurv(rtChord, ...
                          CHORD_CP_X, ...
                          chord_CP_Y, ...
                          TWIST_CP_X, ...
                          twist_CP_Y, ...
                          foil_CP_X, ...
                          perThick_tmp, ...
                          BLADE)
                     
[chord twist perThick dimThick] = bladeGeomCircRt(rtChord, ...
                                                  CHORD_CP_X, ...
                                                  chord_CP_Y, ...
                                                  TWIST_CP_X, ...
                                                  twist_CP_Y, ...
                                                  foil_CP_X, ...
                                                  perThick_tmp, ...
                                                  BLADE);

% check that percent thickness and dimensional thickness are decreasing
dPT = perThick(2:end) - perThick(1:end-1);
dDT = dimThick(2:end) - dimThick(1:end-1);
p1  = max(dPT);     % penalty factor
p2  = max(dDT);     % penalty factor
w   = 1e12;         % weighting factor

% curvature metric
dtdr   = finiteDiff(dimThick) ./ finiteDiff(BLADE.R_ELM);  	% slope of dimensional thickness
d2tdr2 = finiteDiff(dtdr)     ./ finiteDiff(BLADE.R_ELM);	% curvature of dimensional thickness
curv   = sum( abs(d2tdr2) ) + w*(p1 + p2);                	% curvature metric
% curv   = max( abs(d2tdr2) ) + w*(p1 + p2);
% curv   = sum( abs(d2tdr2) ); 
% curv    = max(abs(d2tdr2));

% NOTE: the "curvature metric" really changes the shape of the blade alot,
% not really sure the best way to define this...experiment...
% maybe define a user input that controls this.  Depending on how you
% define this "curvature metric" that gets minimized, the blade could be
% skinny or fat at the root, or somewhere in-between.

% subplot(5,1,1)
% plot(BLADE.R_ELM, chord, '.-b');
% ylabel('c')
% subplot(5,1,2)
% plot(BLADE.R_ELM, perThick, '.-k');
% ylabel('t/c')
% subplot(5,1,3)
% plot(BLADE.R_ELM, dimThick, '.-k');
% ylabel('t')
% subplot(5,1,4)
% plot(BLADE.R_ELM, dtdr, '.-k');
% ylabel('dt/dr')
% subplot(5,1,5)
% plot(BLADE.R_ELM, d2tdr2, '.-k');
% ylabel('d2t/dr2')
% drawnow

end % function bladeCurv

%=======================================

function [chord twist perThick dimThick cps] = bladeGeomCircRt(rtChord, ...
                                                               CHORD_CP_X, ...
                                                               chord_CP_Y, ...
                                                               TWIST_CP_X, ...
                                                               twist_CP_Y, ...
                                                               foil_CP_X, ...
                                                               perThick_tmp, ...
                                                               BLADE)

% calculate chord distribution
chord_CP_Y_cr = [rtChord; rtChord; chord_CP_Y(1); chord_CP_Y];
chord         = interp1Bez(CHORD_CP_X, chord_CP_Y_cr, BLADE.R_ELM);
chord(BLADE.R_ELM <= CHORD_CP_X(1)) = rtChord;

% find value & location of max chord
[unused i_maxChord] = max(chord);
r_maxChord = BLADE.R_ELM(i_maxChord);

% calculate twist distribution
twist = interp1Bez(TWIST_CP_X, twist_CP_Y, BLADE.R_ELM); % note: NaN's can be present due to extrapolation
twist(isnan(twist)) = twist_CP_Y(1);
if r_maxChord > TWIST_CP_X(1)
    twist(1:i_maxChord) = twist(i_maxChord);
end

% calculate dimensional thickness
dimThick = chord.*perThick_tmp./100;

% blend the dimensional thickness from circle to the first true airfoil
ii    = findClosest(BLADE.R_ELM, CHORD_CP_X(1));
jj    = findClosest(BLADE.R_ELM, foil_CP_X(1));
x1    = BLADE.R_ELM(ii);
x2    = BLADE.R_ELM(jj);
f1    = rtChord;
f2    = dimThick(jj);
dfdx  = finiteDiff(dimThick) ./ finiteDiff(BLADE.R_ELM);
dfdx1 = 0;
dfdx2 = dfdx(jj);

dimThick(ii:jj) = cubicFit(x1, x2, f1, f2, dfdx1, dfdx2, BLADE.R_ELM(ii:jj));
dimThick(1:ii)  = rtChord; 

% re-calculate the percent thickness
perThick = 100.*dimThick./chord;

% control points
cps.twist_cp_x = TWIST_CP_X;
cps.twist_cp_y = twist_CP_Y;
cps.chord_cp_x = CHORD_CP_X;
cps.chord_cp_y = chord_CP_Y_cr;
cps.foil_cp_x  = foil_CP_X;

end % function bladeGeomCircRt


