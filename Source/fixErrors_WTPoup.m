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

function [power, Cp, numBadCases] = fixErrors_WTPoup(WTPoup,flag)
%% interpolate for any unconverged or erroneous values in the WT_Perf analysis
% NOTE: tested with WT_Perf v3.05.00a-adp

numCases = numel(WTPoup.power);           
        
i_badCp  = WTPoup.Cp    > 0.593;    % assume we cannot break the Betz limit, this can also be expected when WT_Perf crashses
i_nanCp  = isnan(WTPoup.Cp);        % this can be expected when WT_Perf crashes
i_nanPwr = isnan(WTPoup.power);     % this can be expected when WT_Perf crashes
i_noConv = ~WTPoup.converge;        
if any(i_badCp) || any(i_nanCp) || any(i_nanPwr) || any(i_noConv)
    i_badCase   = i_badCp | i_nanCp | i_nanPwr | i_noConv;
    numBadCases = sum(i_badCase);
    
    if numCases > 1
        % try to fix the bad values by interpolating
        switch flag
          case 'vel'
              power = interp1(WTPoup.vel(~i_badCase), WTPoup.power(~i_badCase), WTPoup.vel, 'pchip');   
              Cp    = interp1(WTPoup.vel(~i_badCase), WTPoup.Cp(~i_badCase),    WTPoup.vel, 'pchip'); 
          case 'tsr'
              power = interp1(WTPoup.tsr(~i_badCase), WTPoup.power(~i_badCase), WTPoup.tsr, 'pchip');   
              Cp    = interp1(WTPoup.tsr(~i_badCase), WTPoup.Cp(~i_badCase),    WTPoup.tsr, 'pchip'); 
        end
    else
        power       = 0; 
        Cp          = 0;
    end
             
else
    numBadCases = 0;
    power       = WTPoup.power;
    Cp          = WTPoup.Cp;

end

