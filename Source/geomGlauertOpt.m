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

function [glauert] = geomGlauertOpt(TURB,BLADE,OPT)
% This function computed the chord, twist, and solidity of a Glauert/Betz
% optimal rotor with wake rotation, assuming Cd = 0. Formulas taken from
% "Wind Energy Explained, Section 3.9" by Manwell et al..
%
% Inputs: TURB.NUM_BLADES
%             .ROTOR_RAD
%         BLADE.r_R     = radius/maxRadius
%              .R_ELM   = radius of blade elements
%         OPT.guess.Cl  = lift coeff at max cl/cd
%                  .tsr = tsr guess for optimal rotor
%                  .aoa = angle of attache at max cl/cd
%
% @author:mlawson
% @data:July 25, 2012

tsr_r             = OPT.guess.tsr*BLADE.r_R; % tsr as a function of blade radius
glauert.phi.rad   = 2./3.*atan(1./tsr_r); % angle of relative wind
% glauert.phi.deg = rad2deg(glauert.phi.rad);
glauert.phi.deg   = glauert.phi.rad * 180/pi;
glauert.twist.rad = glauert.phi.rad - OPT.guess.aoa; % corresponding blade twist angle
% glauert.twist.deg = rad2deg(glauert.twist.rad);
glauert.twist.deg = glauert.twist.rad * 180/pi;
glauert.c         = 8*pi.*BLADE.R_ELM./(TURB.NUM_BLADES.*OPT.guess.Cl).*(1 - cos(glauert.phi.rad)); % chord length    
glauert.c_R       = glauert.c./TURB.ROTOR_RAD; % chord / turb radius
glauert.solidity  = TURB.NUM_BLADES/(length(TURB.NUM_BLADES)*pi)*sum(glauert.c/TURB.ROTOR_RAD); % rotor solidity

% if strcmp(OPT.PLOT_GLAUERT,'true') == 1
%     figure; subplot(3,1,1);
%     plot(BLADE.r_R,glauert.twist.deg)
%     ylabel('Airfoil twist (deg)')
%     subplot(3,1,2);
%     plot(BLADE.r_R,glauert.c)
%     ylabel('Chord length (m)')
%     subplot(3,1,3);
%     plot(BLADE.r_R,glauert.c_R)
%     ylabel('Chord length / Radius')
% end

end
