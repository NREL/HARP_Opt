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

