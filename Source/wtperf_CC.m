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

function WTPoup = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE)

if strcmp(state,'final')
	WTP.writeBED = true;
else
	WTP.writeBED = false;
end
WTP.inpTSR      = false;
WTP.analysisWTP = 'cc';

% write WT_Perf input file and execute
writeInpFileWTPerf(WTP,SIM,TURB,CAV,ENV,BLADE); 
cd(SIM.outputDir)
[SIM.status SIM.consoleMsg] = system([SIM.wtpExe ' ' SIM.caseName '.wtp']);
cd(SIM.rootDir)
if SIM.DEBUG_LVL >= 2
	fprintf(1, ['\n [wtperf_CC.m] WT_Perf console output is: \n' SIM.consoleMsg]);
end

% read WT_Perf output, fixing any potential errors
 WTPoup                   = readOutFileWTPerf(SIM,WTP,'cc');
[WTPoup.power, WTPoup.Cp] = fixErrors_WTPoup(WTPoup,'vel');


end % function wtperf_CC()

