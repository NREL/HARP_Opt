function writeInpFileWTPerf(WTP,SIM,TURB,CAV,ENV,BLADE)
    
date = datestr(now, 'mmmm dd, yyyy HH:MM AM');
                        
%% write the WT_Perf input file
fid = fopen([SIM.outputDir filesep SIM.caseName '.wtp'],'w');
if fid == -1
    error(['ERROR: Could not locate and open file' SIM.outputDir filesep SIM.caseName '.wtp']);
end

fprintf(fid,'-----  WT_Perf Input File  -----------------------------------------------------\r\n');
fprintf(fid,'Generated automatically by HARP_Opt version %s on %s \r\n', SIM.version, date);
fprintf(fid,'Compatible with WT_Perf v3.05.00a-adp.\r\n');
fprintf(fid,'-----  Input Configuration  ----------------------------------------------------\r\n');
fprintf(fid,'%s     Echo:          Echo input parameters to "<rootname>.ech"?\r\n', 'false');
fprintf(fid,'%s     DimenInp:      Turbine parameters are dimensional?\r\n', 'true ');
fprintf(fid,'%s     Metric:        Turbine parameters are Metric (MKS vs FPS)?\r\n', 'true ');
fprintf(fid,'-----  Model Configuration  ----------------------------------------------------\r\n');
fprintf(fid,'%-9.0f NumSect:       Number of circumferential sectors.\r\n', WTP.NUM_SECT);
fprintf(fid,'%-9.0f MaxIter:       Max number of iterations for Newton''s method to find induction factor.\r\n', WTP.MAX_ITER);
fprintf(fid,'%-9.0f NSplit:        Max number of iterations for binary search to find induction factor.\r\n', WTP.NSplit);
fprintf(fid,'%-9.1e ATol:          Error tolerance for induction iteration.\r\n', WTP.IND_TOL);
fprintf(fid,'%-9.1e SWTol:         Error tolerance for skewed-wake iteration.\r\n', WTP.SW_TOL);
fprintf(fid,'-----  Algorithm Configuration  ------------------------------------------------\r\n');
fprintf(fid,'%s     TipLoss:       Use the Prandtl tip-loss model?\r\n', strTF(WTP.TIP_LOSS));
fprintf(fid,'%s     HubLoss:       Use the Prandtl hub-loss model?\r\n', strTF(WTP.HUB_LOSS));
fprintf(fid,'%s     Swirl:         Include Swirl effects?\r\n', strTF(WTP.SWIRL));
fprintf(fid,'%s     SkewWake:      Apply skewed-wake correction?\r\n', strTF(WTP.SKEW_WAKE));
fprintf(fid,'%s     IndType:       Use BEM induction algorithm?\r\n', strTF(WTP.IND_TYPE));
fprintf(fid,'%s     AIDrag:        Use the drag term in the axial induction calculation?\r\n', strTF(WTP.AI_DRAG));
fprintf(fid,'%s     TIDrag:        Use the drag term in the tangential induction calculation?\r\n', strTF(WTP.TI_DRAG));
fprintf(fid,'%s     TISingularity: Use the singularity avoidance method in the tangential-induction calculation?\r\n', strTF(WTP.TI_SINGULARITY));
fprintf(fid,'%s     DAWT:          Run Diffuser Augmented Water Turbine Analysis?\r\n', 'false');
fprintf(fid,'%s     Cavitation:    Run cavitation check? checks 12 oclock azimuth\r\n', strTF(CAV.CAVITATION));
fprintf(fid,'-----  Cavitation Model  -------------------------------------------------------\r\n');
fprintf(fid,'%-9.1f PressAtm:      Air Atmospheric Pressure, Pa units, absolute\r\n', CAV.ATM_PRESS);
fprintf(fid,'%-9.3f PressVapor:    Vapor Pressure of Water, Pa units, absolute\r\n', CAV.VAPOR_PRESS);
fprintf(fid,'%-9.3f CavSF:         Cavitation safety factor\r\n', CAV.SF_CAV);
fprintf(fid,'%-9.3f WatDepth:      Depth from water free surface to mudline (tower base)\r\n', CAV.WAT_DEPTH);
fprintf(fid,'-----  Turbine Data  -----------------------------------------------------------\r\n');
fprintf(fid,'%-9.0f NumBlade:      Number of blades.\r\n', TURB.NUM_BLADES);
fprintf(fid,'%-9.3f RotorRad:      Rotor radius [length].\r\n', TURB.ROTOR_RAD);
fprintf(fid,'%-9.3f HubRad:        Hub radius [length or div by radius].\r\n', TURB.HUB_RAD);
fprintf(fid,'%-9.3f PreCone:       Precone angle, positive downstream [deg].\r\n', TURB.PRE_CONE);
fprintf(fid,'%-9.3f Tilt:          Shaft tilt [deg].\r\n', TURB.SHAFT_TILT);
fprintf(fid,'%-9.3f Yaw:           Yaw error [deg].\r\n', 0);
fprintf(fid,'%-9.3f HubHt:         Hub height [length or div by radius].\r\n', TURB.HUB_HT);
fprintf(fid,'%-9.0f NumSeg:        Number of blade segments (entire rotor radius).\r\n', WTP.NUM_SEG);
fprintf(fid,'RElm        Twist       Chord    AFfile       PrntElem\r\n');

fprintf(fid,'%-9.3f   %-9.3f   %-9.3f   %-9.0f   true\r\n',[BLADE.R_ELM, BLADE.twist, BLADE.chord, (1:WTP.NUM_SEG)']');

fprintf(fid,'-----  Aerodynamic Data  -------------------------------------------------------\r\n');
fprintf(fid,'%-9.3f Rho:           Air density [mass/volume].\r\n', ENV.DENSITY);
fprintf(fid,'%-9.2e KinVisc:       Kinematic air viscosity.\r\n', ENV.KIN_VISC);
fprintf(fid,'%-9.3f ShearExp:      Wind shear exponent (1/7 law = 0.143).\r\n', ENV.SHEAR_EXP);
fprintf(fid,'%s     UseCm:         Are Cm data included in the airfoil tables?\r\n', strTF(WTP.USE_CM));
fprintf(fid,'%s     UseCpmin:      Are Cp,min data included in the airfoil tables?\r\n', strTF(WTP.USE_CPMIN));
fprintf(fid,'%-9.0f NumAF:         Number of airfoil files.\r\n', WTP.NUM_SEG);

fprintf(fid,'%s\r\n', BLADE.foilFileStr{:});

fprintf(fid,'-----  I/O Settings  -----------------------------------------------------------\r\n');
fprintf(fid,'%s     UnfPower:      Write parametric power to an unformatted file?\r\n', 'false');
fprintf(fid,'%s     TabDel:        When generating formatted output (OutForm=True), make output tab-delimited (fixed-width otherwise).\r\n', 'false');
fprintf(fid,'2         ConvFlag:      For non-converging cases, 0 to output the result, 1 to output nines, 2 to output NaN (safest).\r\n');
fprintf(fid,'%s     Beep:          Beep on exit.\r\n', 'false');
fprintf(fid,'%s     KFact:         Output dimensional parameters in K (e.g., kN instead on N)\r\n', 'true ');
fprintf(fid,'%s     WriteBED:      Write out blade element data to "<rootname>.bed"?\r\n', strTF(WTP.writeBED));
fprintf(fid,'%s     InputTSR:      Input speeds as TSRs?\r\n', strTF(WTP.inpTSR));
fprintf(fid,'%s     OutMaxCp:      Output conditions for the maximum Cp?\r\n', 'false');
fprintf(fid,'%s     SpdUnits:      Wind-speed units (mps, fps, mph)\r\n','mps  ');

switch WTP.analysisWTP
    case 'cc'
    fprintf(fid,'-----  Combined-Case Analysis  -------------------------------------------------\r\n');
    fprintf(fid,'%-9.0f NumCases:  Number of cases to run. Enter 0 for parametric analysis\r\n', WTP.NUM_CASES);
    fprintf(fid,'WS or TSR    RotSpd    Pitch                      Remove following block of lines if NumCases is zero.\r\n');
    fprintf(fid,'%-9.6f   %-9.6f   %-9.6f\r\n', [WTP.spd WTP.rotSpd WTP.pitch]');
    
    case 'para'
    fprintf(fid,'-----  Combined-Case Analysis  -------------------------------------------------\r\n');
    fprintf(fid,'0      NumCases:      Number of cases to run. Enter 0 for parametric analysis\r\n');
    fprintf(fid,'WS or TSR   RotSpd   Pitch                      Remove following block of lines if NumCases is zero.\r\n');
    fprintf(fid,'-----  Parametric Analysis (Ignored if NumCases > 0 )  -------------------------\r\n');
    fprintf(fid,'%-9.0f ParRow:        Row parameter    (1-rpm, 2-pitch, 3-tsr/speed)\r\n', 3);
    fprintf(fid,'%-9.0f ParCol:        Column parameter (1-rpm, 2-pitch, 3-tsr/speed)\r\n', 2);
    fprintf(fid,'%-9.0f ParTab:        Table parameter  (1-rpm, 2-pitch, 3-tsr/speed)\r\n', 1);
    fprintf(fid,'%s     OutPwr:        Request output of rotor power?\r\n', strTF(WTP.oupPwr));
    fprintf(fid,'%s     OutCp:         Request output of Cp?\r\n', strTF(WTP.oupCp));
    fprintf(fid,'%s     OutTrq:        Request output of shaft torque?\r\n', strTF(WTP.oupTrq));
    fprintf(fid,'%s     OutFlp:        Request output of flap bending moment?\r\n', strTF(WTP.oupFlp));
    fprintf(fid,'%s     OutThr:        Request output of rotor thrust?\r\n', strTF(WTP.oupThr));
    fprintf(fid,'%-9.6f, %-9.6f, %-9.6f   PitSt, PitEnd, PitDel: First, last, delta blade pitch (deg)\r\n', WTP.pitSt, WTP.pitEnd, WTP.pitDel);
    fprintf(fid,'%-9.6f, %-9.6f, %-9.6f   OmgSt, OmgEnd, OmgDel: First, last, delta rotor speed (rpm)\r\n', WTP.omgSt, WTP.omgEnd, WTP.omgDel);
    fprintf(fid,'%-9.6f, %-9.6f, %-9.6f   SpdSt, SpdEnd, SpdDel: First, last, delta flow speed\r\n',        WTP.spdSt, WTP.spdEnd, WTP.spdDel);
end

fclose(fid);

end % function writeInpFileWTPerf

% convert to true false arguments
function tf = strTF(TrueFalse)
if TrueFalse
    tf = 'true ';
else
    tf = 'false';
end

end % function strTF
