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

function AEP = calcAEP(VEL,pwr,FLOW_DIST,VEL_DIST)
                                     
switch FLOW_DIST      
    case 'Hist'
        % VEL_DIST contains data for a histogram, use method of bins   
        % interpolate the power curve to the midpoints of the histogram bins
        midptPwr  = interp1q(VEL, pwr, VEL_DIST.BIN_CENTERS);
        midptPwr(isnan(midptPwr)) = 0; %overwrite any NAN values that were extrapolated
        AEP       = sum(8760.*VEL_DIST.FRAC_OCCURNCE.*midptPwr); %(kW-hrs/year)
        
    otherwise
        % VEL_DIST contains data for a probability distribution function
        avgPwr    = trapzf(VEL, pwr.*VEL_DIST);
        AEP       = avgPwr*8760; %(kW-hrs/year)

end



