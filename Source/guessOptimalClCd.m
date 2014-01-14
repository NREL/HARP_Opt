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

function OPT = guessOptimalClCd(OPT,TURB,AF)
OPT.guess.tsr  = 4*pi/TURB.NUM_BLADES;                      % make a guess at the optimal tip speed ratio
[OPT.guess.L_D OPT.guess.designL_D_ind] = max(AF.maxL_D);   % why are we picking the maximum l/d across all reynolds numbers instead of the Reynolds number at which the blade OPT.objectivections?
OPT.guess.Cl   = AF.maxCl_AoA(OPT.guess.designL_D_ind);
OPT.guess.aoa  = AF.maxL_D_AoA(OPT.guess.designL_D_ind) * pi/180;