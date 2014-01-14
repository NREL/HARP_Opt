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

function f = optFitness(x0,SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state)

%% separate the subsets of design variables
x_aero   = x0;      
% x_struct = x0(?); 

if strcmp(OPT.STRUCT,'none')
    f = zeros(1, 1); % there is only 1 objective
else
    f = zeros(2, 1); % there are 2 objectives
end

%% single objective
[f(1), BLADE, WTP, WTPoup] = optAero(x_aero,    SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state);
% f = f_aero:
% f = fstruct / f_aero;
% f = f_aero:

%% multiple objective
switch OPT.STRUCT
    case 'CoBlade'
        % derives some kind of structural objective from CoBlade
%         f_struct = optStruct(WTPoup);
%         f(2) = f_struct;

        % create a Co-Blade input file
        % harpOpt2coBlade(SIM.inpFile) this refers to a CoBlade input file

        % now run a CoBlade parametric analysis

        % read the output files

        % assign the structural fitness function

        
    case 'WT_Perf'
        % derives some kind of structural objective from WT_Perf
        f_struct = optStruct(WTPoup);
        f(2) = f_struct;
        
    case 'none'
        return
        
    otherwise
        
end



