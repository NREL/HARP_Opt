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

function rpm = find_rpm(WTPoup,state,WTP,SIM,TURB,CAV,ENV,BLADE)
       
% find the flow speeds for region 3 (where power is above rated power and rpm will vary to shed excess power & loads)
for n = 1:ENV.NUM_CASES
    if WTPoup.power(n) >= TURB.RATED_PWR; 
        i_reg3 = n;
        break
    end
end
V_reg3 = ENV.VEL(i_reg3:end);

LB = TURB.RPM_MIN;
UB = TURB.RPM_MAX;
options = optimset('Algorithm',              'interior-point', ...
				   'AlwaysHonorConstraints', 'bounds', ...                       
				   'Diagnostics',            'off', ...
				   'Display',                'off', ... % 'iter-detailed'
				   'FinDiffType',            'central', ...
				   'ScaleProblem',           'obj-and-constr', ...
				   'SubproblemAlgorithm ',   'cg', ...
				   'Hessian',                'bfgs', ... 
				   'UseParallel',            'never', ...
				   'MaxIter',                20, ...
				   'TolX',                   1e-4, ...
				   'TolFun',                 1e-4); 

rpm_reg3 = WTPoup.rpm(i_reg3:end);
rpm_opt  = zeros(numel(V_reg3), 1);
for n = 1:numel(V_reg3)
        
    WTP.NUM_CASES   = 1;
    WTP.spd         = V_reg3(n); 
    WTP.pitch       = 0;
    FUN             = @(rpm) rpmError(rpm,state,WTP,SIM,TURB,CAV,ENV,BLADE);
    
    % use an optimization algorithm to find the optimal
    % rotor speeds, this could reduce the number of WT_Perf calls
    problem       = createOptimProblem('fmincon','objective',FUN,'x0',rpm_reg3(n),'lb',LB,'ub',UB,'options',options);
    startPts      = CustomStartPointSet(linspace(LB,UB,5)');    
    [xBest, fval] = run(MultiStart,problem,startPts);
    rpm_opt(n)    = xBest;

end

rpm             = WTPoup.rpm;
rpm(i_reg3:end) = rpm_opt;


end %function find_rpm()

% =============================================================================
function f = rpmError(pitch,state,WTP,SIM,TURB,CAV,ENV,BLADE)
    
WTP.rotSpd = pitch;
WTPoup     = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);

res = (WTPoup.power - TURB.RATED_PWR)^2; %residual from rated power
f   = res;

end % function rpmError()