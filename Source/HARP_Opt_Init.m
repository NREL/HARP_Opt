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

function [BLADE,CAV,ENV,OPT,SIM,TURB,WTP,AF_outboard] = HARP_Opt_Init(inputFile)

% Harp_Opt version
SIM.version = '3.00.00_RC1';

% Get the parts of the input file
[SIM.pathStr, SIM.caseName, SIM.inpExt] = fileparts(inputFile);

% Define the input file absolute path
SIM.inpFile = [pwd filesep 'Input' filesep SIM.caseName SIM.inpExt];

% Read the HARP-Opt input files
[DEV,OPT,TURB,ENV,BLADE,CAV,WTP] = parseInputFile(SIM.inpFile); % NOTE: this method uses eval() but will eval() work with compiled programs?
SIM.DEBUG_LVL = DEV.DEBUG_LVL;

% Define directories in the solution path
SIM.rootDir             = pwd;
SIM.sourceDir           = [SIM.rootDir   filesep 'Source'];
SIM.outputDir           = [SIM.rootDir   filesep 'Output' filesep SIM.caseName];
SIM.airfoilData         = [SIM.outputDir filesep 'Airfoil_Data'];
SIM.airfoilInputData    = [SIM.rootDir   filesep 'Input' filesep 'Airfoil_Data'];
SIM.flowFile            = [SIM.rootDir   filesep 'Input' filesep 'Inflow_Data' filesep ENV.FLOW_FILE];
SIM.optimizationOptions = [SIM.rootDir   filesep 'Input' filesep 'Optimization_Options'];
SIM.logfile             = [SIM.outputDir filesep SIM.caseName '_Log.txt'];
SIM.xlsfile             = [SIM.outputDir filesep SIM.caseName '.xls'];
SIM.matfile             = [SIM.outputDir filesep SIM.caseName '.mat'];
SIM.tag                 = SIM.caseName;

% Define the output directories
if exist([SIM.rootDir filesep 'Output'],'dir') == 0
    mkdir([SIM.rootDir filesep 'Output']);
end
if exist(SIM.outputDir,'dir') == 7
    SIM.outputDir;
    rmdir(SIM.outputDir,'s');
    mkdir(SIM.outputDir);
else
    mkdir(SIM.outputDir);
end
mkdir([SIM.outputDir filesep 'Airfoil_Data']);
mkdir([SIM.outputDir filesep 'Optimization_Options']);

% reset ALL the random number generators (rand, randn, randi)
rng(DEV.RAND_SEED);

% Start a log of all text and command line output. Read this file if
% something goes wrong and follow the error handling messages to debug.
diary(SIM.logfile);
fprintf(1, ['\n\n Executing HARP_Opt version ' SIM.version ' for case ' SIM.caseName '.\n\n']);

% % read user parameters
% if isdeployed
%     readUserCtrlFile('settings')    % NOTE: not implemented yet, use this method for compiling
% else
%     user_parameters
% end

% echo user parameters to output directory
copyfile([SIM.inpFile],[SIM.outputDir filesep SIM.caseName '_echo' SIM.inpExt]);

% Deal with the WT_Perf executiable
SIM.wtpExe = [SIM.rootDir filesep WTP.wtpExe];
if exist([SIM.rootDir filesep WTP.wtpExe]) == 0
    error(['ERROR: could not find WT_Perf executable ' [SIM.rootDir filesep WTP.wtpExe]])
end

% Define auxilliary input files
switch OPT.ALG
    case 'GradientSearch';     SIM.optFile = [SIM.optimizationOptions filesep 'options_GradientSearch.inp'];
    case 'PatternSearch';      SIM.optFile = [SIM.optimizationOptions filesep 'options_PatternSearch.inp'];
    case 'ParticleSwarm';      SIM.optFile = [SIM.optimizationOptions filesep 'options_ParticleSwarm.inp'];
    case 'GeneticAlgorithm';   SIM.optFile = [SIM.optimizationOptions filesep 'options_GeneticAlgorithm.inp'];
    case 'MOGeneticAlgorithm'; SIM.optFile = [SIM.optimizationOptions filesep 'options_MOGeneticAlgorithm.inp'];
end

% Define the airfoil coord and data files
BLADE.FOIL_VALS = sort(BLADE.FOIL_VALS, 'descend'); % make sure values are sorted
BLADE.FOIL_VALS = BLADE.FOIL_VALS(:);               % make sure it is a column vector
switch BLADE.ROOT_STYLE
    case       'foil';   foilVals = BLADE.FOIL_VALS;
    case       'circle'; foilVals = [100; BLADE.FOIL_VALS(:)]; % add the airfoil data for a circle
    otherwise; error('ERROR: Unrecognized value for BLADE.ROOT_STYLE.')
end
BLADE.foilCoefFiles = cellstr(strcat(BLADE.FOIL_FAM,'_',num2str(10.*foilVals,'%04.0f'),'.dat'));

% Copy files to the output directory
copyfile(SIM.inpFile,SIM.outputDir);
copyfile(SIM.wtpExe,SIM.outputDir);
copyfile(SIM.optFile,[SIM.outputDir filesep 'Optimization_Options']);
if strcmp(OPT.AERO,'AEP') && strcmp(ENV.FLOW_DIST, 'Hist')
    mkdir([SIM.outputDir filesep 'Flow_Data']);
    copyfile(SIM.flowFile,[SIM.outputDir filesep 'Flow_Data']);
end
for n = 1:numel(foilVals) % copy airfoil data files to the output directory (only need the files that are actually used in this simulation)
    copyfile([SIM.airfoilInputData filesep BLADE.foilCoefFiles{n}], ...
             [SIM.outputDir filesep 'Airfoil_Data' filesep BLADE.foilCoefFiles{n}]);
end

% Interpolate airfoil coefficients
for n = 1:numel(foilVals)-1;
    afc_file1 = fullfile(SIM.airfoilData,BLADE.foilCoefFiles{n});
    afc_file2 = fullfile(SIM.airfoilData,BLADE.foilCoefFiles{n+1});
    thickVal1 = foilVals(n);
    thickVal2 = foilVals(n+1);
    interpAFcoefs(afc_file1,...
                  afc_file2,...
                  thickVal1,...
                  thickVal2,...
                  BLADE.FOIL_FAM, ...
                  SIM.outputDir,...
                  WTP.INTERP_COEFS, ...
                  SIM);                                     
end
clear afc_file1 afc_file2 thickVal1 thickVal2 afp_file1 afp_file2

% Define blade variables
TURB.ROTOR_RAD  = TURB.ROTOR_DIA/2;
TURB.HUB_RAD    = TURB.HUB_DIA/2;
TURB.BLD_LENGTH = TURB.ROTOR_RAD - TURB.HUB_RAD;

% Define the velocities the simulations will consider
ENV.VEL       = (ENV.SPD_ST:ENV.SPD_DEL:ENV.SPD_END)';
ENV.NUM_CASES = numel(ENV.VEL);

% Define the number of control points
BLADE.NUM_CP      = numel(BLADE.CPS); 
BLADE.CPS_DIM     = BLADE.CPS*TURB.ROTOR_RAD; % dimensional radius of the control points, as opposed to non-dimensional radius (r/R)
BLADE.NUM_FOILS   = numel(BLADE.FOIL_VALS);
BLADE.FOIL_LB_DIM = BLADE.FOIL_LB.*TURB.ROTOR_RAD;
BLADE.FOIL_UB_DIM = BLADE.FOIL_UB.*TURB.ROTOR_RAD;

% Define blade element spacing used in BEMT analysis
BLADE = setElmSpacing(BLADE,TURB,WTP);

% Define the velocity distribution
switch OPT.AERO
    case 'AEP'; ENV.VEL_DIST = getFlowPDF(SIM, ENV);
    case 'eff'; ENV.VEL_DIST = nan(ENV.NUM_CASES,1);
end

% depth and pressures used to check for cavitation
CAV.LOC_DEPTH  = CAV.WAT_DEPTH - TURB.HUB_HT - BLADE.R_ELM*cosd(TURB.SHAFT_TILT)*cosd(TURB.PRE_CONE);
CAV.ABS_PRESS  = CAV.ATM_PRESS + ENV.DENSITY*ENV.GRAV.*CAV.LOC_DEPTH;
CAV.PRESS_DIFF = CAV.ABS_PRESS - CAV.SF_CAV*CAV.VAPOR_PRESS;

% Define control points for the twist, chord, and airfoil distributions
OPT = setControlPoints(BLADE,OPT,TURB);

% Set the bounds on the twist, chord, and airfoil distribution
OPT = setBounds(TURB,BLADE,OPT);

% Determine the Cl and AOA at max(Cl/Cd)
AF_outboard = readAFfile(fullfile(SIM.outputDir,'Airfoil_Data',BLADE.foilCoefFiles{end})); % most of the power is generated ~75 % span, so just choose the most outboard airfoil for this guess
OPT = guessOptimalClCd(OPT,TURB,AF_outboard);

% Calculate the chord and twist based on the Glauert optimum geometry
glauert = geomGlauertOpt(TURB,BLADE,OPT);

% Now fit Bezier curve control points to the chord and twist distributions
emptyMat = zeros(BLADE.NUM_CP-1,1);
switch BLADE.ROOT_STYLE  
    case 'foil'
            OPT.CP_CHORD_Y = fitBezier(BLADE.R_ELM,         glauert.c, OPT.CP_CHORD_X, OPT.Atc, emptyMat, BLADE.CHORD_LB, BLADE.CHORD_UB);
        if BLADE.DEC_TWIST; 
            OPT.CP_TWIST_Y = fitBezier(BLADE.R_ELM, glauert.twist.deg, OPT.CP_TWIST_X, OPT.Atc, emptyMat, BLADE.TWIST_LB, BLADE.TWIST_UB);
        else
            OPT.CP_TWIST_Y = fitBezier(BLADE.R_ELM, glauert.twist.deg, OPT.CP_TWIST_X,      [],       [], BLADE.TWIST_LB, BLADE.TWIST_UB);
        end
    case 'circle'
        ii = BLADE.R_ELM >= BLADE.CPS_DIM(1);     
            OPT.CP_CHORD_Y = fitBezier(BLADE.R_ELM(ii),         glauert.c(ii), BLADE.CPS_DIM, OPT.Atc, emptyMat, BLADE.CHORD_LB, BLADE.CHORD_UB);
        if BLADE.DEC_TWIST; 
            OPT.CP_TWIST_Y = fitBezier(BLADE.R_ELM(ii), glauert.twist.deg(ii), BLADE.CPS_DIM, OPT.Atc, emptyMat, BLADE.TWIST_LB, BLADE.TWIST_UB);
        else
            OPT.CP_TWIST_Y = fitBezier(BLADE.R_ELM(ii), glauert.twist.deg(ii), BLADE.CPS_DIM,      [],       [], BLADE.TWIST_LB, BLADE.TWIST_UB);
        end
end
clear emptyMat

% define the percent thickness distribution (just use average of bounds)
OPT.CP_FOIL_X = (BLADE.FOIL_LB_DIM + BLADE.FOIL_UB_DIM)'./2';

% the initial values for the aerodynamic variables
switch TURB.CONTROL
    case {'FSFP','FSVP_S','FSVP_F'}
        % guess for the rotor speed
        switch OPT.AERO
            case 'eff'
                rotSpd = (TURB.RPM_MIN + TURB.RPM_MAX)/2;
            case 'AEP'
                % try to find the velocity where most of the energy exists,
                % and then use this velocity to compute the rotor speed
                % from the guess for tip-speed-ratio
                switch ENV.FLOW_DIST
                    case 'Hist'
                        energyDen   = 0.5*ENV.DENSITY*ENV.VEL_DIST.BIN_CENTERS.^3.*ENV.VEL_DIST.FRAC_OCCURNCE.*8760;  % energy density (kW-hr/year-m^2)
                        [unused ii] = max(energyDen);
                        velMaxE     = ENV.VEL_DIST.BIN_CENTERS(ii);                 % most of the energy is at this velocity
                        rotSpd      = OPT.guess.tsr*velMaxE*30/(pi*TURB.ROTOR_RAD);
                    case 'Weibull'
                        velMaxE     = ENV.K_WBL*(1 + 2/ENV.C_WBL)^(1/ENV.C_WBL);    % most of the energy is at this velocity
                        rotSpd      = OPT.guess.tsr*velMaxE*30/(pi*TURB.ROTOR_RAD);
                    case 'Rayleigh'
                        rotSpd      = OPT.guess.tsr*ENV.MEAN_RAY*30/(pi*TURB.ROTOR_RAD);
                    otherwise
                        rotSpd      = (TURB.OMG_MIN + TURB.OMG_MAX)/2;
                end      
        end
        OPT.x0 = [OPT.CP_TWIST_Y; OPT.CP_CHORD_Y; OPT.CP_FOIL_X; rotSpd];
    case {'VSFP','VSVP_S','VSVP_F'}
        % guess the optimal tip speed ratio
        optTSR = 4*pi/TURB.NUM_BLADES;
        if optTSR < TURB.TSR_MIN
            optTSR = TURB.TSR_MIN;
        end
        if optTSR > TURB.TSR_MAX
            optTSR = TURB.TSR_MAX;
        end
        OPT.x0 = [OPT.CP_TWIST_Y; OPT.CP_CHORD_Y; OPT.CP_FOIL_X; optTSR]; 
end

% compute the ideal power curve
pwr_Betz      = 0.5.*ENV.DENSITY.*pi.*(TURB.ROTOR_RAD.^2).*(ENV.VEL.^3).*(16/27)./1000; % (kW)
OPT.pwr_ideal = pwr_Betz;
OPT.pwr_ideal(OPT.pwr_ideal > TURB.RATED_PWR) = TURB.RATED_PWR;

% create the OPT.objective handle for the optimization fitness function
state = 'iter';
% OPT.objective = @(x0) optAero(x0,SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state);
OPT.objective = @(x0) optFitness(x0,SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state);
OPT.numVars   = numel(OPT.x0);

% =============================================================================
% ERROR CHECKING
% =============================================================================
% check for errors in the input data (check for physically incorrect
% data, etc.)  Need to add more error checking here.
if max(BLADE.RT_CPS) >= min(BLADE.CPS) && strcmp(BLADE.ROOT_STYLE,'circle')
    error('ERROR: Values for BLADE.RT_CPS must be less than values for BLADE.CPS.  The control points at the root region of the blade cannot extend beyond the outer control points.)');
end


