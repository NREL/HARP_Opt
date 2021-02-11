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
function HARP_Opt(inputFile)
%HARP_Opt Horizontal Axis Rotor Performance Optimization.
%  _   _  ___ ____________        _____       _   
% | | | |/ _ \| ___ | ___ \      |  _  |     | |  
% | |_| / /_\ | |_/ | |_/ /      | | | |_ __ | |_ 
% |  _  |  _  |    /|  __/       | | | | '_ \| __|
% | | | | | | | |\ \| |          \ \_/ | |_) | |_ 
% \_| |_\_| |_\_| \_\_|           \___/| .__/ \__|
%                         ______       | |        
%                        |______|      |_|        
%
%   HARP_Opt(inputFile) executes the HARP_Opt code for the input file 
%   named by the string inputFile (with the file extension included).
%
%   If using the compiled version of HARP_Opt (because you do not have
%   access to the required toolboxes) type the command:
%   HARP_Opt.exe inputFile
%   at the command prompt, where inputFile is the input file.

% Add the source code directory
if ~isdeployed
    % Everything in this directory is maintained by the HARP_Opt developers
    addpath([pwd filesep 'Source']);
    % These are external dependencies of HARP_Opt
    addpath([pwd filesep 'Source' filesep 'akima']);
    addpath([pwd filesep 'Source' filesep 'fminsearchbnd']);
    addpath([pwd filesep 'Source' filesep 'psopt']);
    addpath([pwd filesep 'Source' filesep 'xlwrite']);
        javaaddpath([pwd filesep 'Source' filesep 'xlwrite' filesep 'poi_library/poi-3.8-20120326.jar']);
        javaaddpath([pwd filesep 'Source' filesep 'xlwrite' filesep 'poi_library/poi-ooxml-3.8-20120326.jar']);
        javaaddpath([pwd filesep 'Source' filesep 'xlwrite' filesep 'poi_library/poi-ooxml-schemas-3.8-20120326.jar']);
        javaaddpath([pwd filesep 'Source' filesep 'xlwrite' filesep 'poi_library/xmlbeans-2.3.0.jar']);
        javaaddpath([pwd filesep 'Source' filesep 'xlwrite' filesep 'poi_library/dom4j-1.6.1.jar']);
end

% Add debug points
% dbstop HARP_Opt 97
% dbstop HARP_Opt_init 7
% dbstop optAero 9
% dbstop optStruct 1
% dbstop find_pitch 65
% dbstop outputFun_GA.m 128
% dbstop optFitness 4
% dbstop writeOupFileXLS 21

% Read the data and initialize the required variables
[BLADE,CAV,ENV,OPT,SIM,TURB,WTP] = HARP_Opt_Init(inputFile);

% Initialize the optimization algorithms
% Read the input file and set the opt algorithm options
[OPT.options]   = parseOptimizationOptions(SIM.optFile);
optPlotFun      = {};
optCustomOutput = [];
switch OPT.ALG
    case 'GradientSearch'
        if OPT.PLOT_ITER
            optPlotFun        = {@optimplotx,@optimplotfunccount,@optimplotfval,@optimplotconstrviolation,@optimplotstepsize,@optimplotfirstorderopt};
%             optCustomOutput = @(x,optimValues,state) outputGradientSearch(x, optimValues, state, otherInputs?);
        end
        OPT.options = optimset(OPT.options, ...
                              'OutputFcns', optCustomOutput, ...
                              'PlotFcns',   optPlotFun, ...
                              'TypicalX',   OPT.x0);
        
    case 'PatternSearch'
        if OPT.PLOT_ITER
            optPlotFun        = {@psplotbestf, @psplotmeshsize ,@psplotfuncount, @psplotbestx};
%             optCustomOutput = @(optimvalues, options, flag) outputPatternSearch(optimvalues, options, flag, otherInputs?);
%             optCustomOutput = @(options, state, flag) outputFun_GA(options, state, flag, ...
%                                                                    BLADE,CAV,ENV,OPT,SIM,TURB,WTP);
        end
        OPT.options = psoptimset(OPT.options, ...
                                'OutputFcns', optCustomOutput, ...
                                'PlotFcns',   optPlotFun);
                          
    case 'ParticleSwarm'
        % find a feasible initial population
        initPop      = constrainedRandomVector(OPT.options.PopulationSize,OPT.lb,OPT.ub,OPT.Aineq,OPT.bineq);
        initPop(:,1) = OPT.x0(:); % include our "modified" Glauert optimum blade in the initial population
        
        if OPT.PLOT_ITER
            optPlotFun        = {@psoplotbestf};
%             optCustomOutput = @(optimvalues, options, flag) outputParticleSwarm(optimvalues, options, flag, otherInputs?);
        end
        OPT.options = psooptimset(OPT.options, ...
                                 'OutputFcns',        optCustomOutput, ...
                                 'PlotFcns',          optPlotFun, ...
                                 'InitialPopulation', initPop');
                
    case 'GeneticAlgorithm'
        % find a feasible initial population
        initPop      = constrainedRandomVector(OPT.options.PopulationSize,OPT.lb,OPT.ub,OPT.Aineq,OPT.bineq);
        initPop(:,1) = OPT.x0(:); % include our "modified" Glauert optimum blade in the initial population
        
        if OPT.PLOT_ITER
            optPlotFun      = {@gaplotbestf, @gaplotbestindiv, @gaplotdistance, @gaplotmaxconstr, @gaplotscores};
            optCustomOutput = @(options, state, flag) outputFun_custom(options, state, flag, ...
                                                                       BLADE,CAV,ENV,OPT,SIM,TURB,WTP);
        end
        OPT.options = gaoptimset(OPT.options, ...
                                'OutputFcns',        optCustomOutput, ...
                                'PlotFcns',          optPlotFun, ...
                                'InitialPopulation', initPop');
                              
    case 'MOGeneticAlgorithm'
        % find a feasible initial population
        initPop      = constrainedRandomVector(OPT.options.PopulationSize,OPT.lb,OPT.ub,OPT.Aineq,OPT.bineq);
        initPop(:,1) = OPT.x0(:); % include our "modified" Glauert optimum blade in the initial population
        
        if OPT.PLOT_ITER
            optPlotFun      = {@gaplotpareto};
            optCustomOutput = @(options, state, flag) outputFun_custom(options, state, flag, ...
                                                                       BLADE,CAV,ENV,OPT,SIM,TURB,WTP);
        end
        OPT.options = gaoptimset(OPT.options, ...
                                'OutputFcns',        optCustomOutput, ...
                                'PlotFcns',          optPlotFun, ...
                                'InitialPopulation', initPop');

end


% need a function to accept variable inputs from the various optimization
% algorithms.  Unfortunately, each algorithm uses non-standard definitions
% for state, flag, optimvalues
% but really, all I need is
% (x,optimValues?,state) = the fitness values 
% (flag) = the current state of the algorithm
% (others) = variables defined outside the scope of the optimization algorithms functions
% switch OPT.ALG
%     case 'GradientSearch'
%         optCustomOutput = @(x,optimValues,state) outputGradientSearch(x, optimValues, state, otherInputs?);
%         options = 
%         state   = 
%         flag    = 
%     case 'PatternSearch'
%         optCustomOutput = @(optimvalues, options, flag) outputPatternSearch(optimvalues, options, flag, otherInputs?);
%         options = 
%         state   = 
%         flag    = 
%     case 'ParticleSwarm'
%         optCustomOutput = @(optimvalues, options, flag) outputParticleSwarm(optimvalues, options, flag, otherInputs?);
%         options = 
%         state   = 
%         flag    = 
%     case 'GeneticAlgorithm'
%         optCustomOutput = @(options, state, flag) outputFun_GA(options, state, flag, ...
%                             'InitialPopulation', initPop');
%         options = 
%         state   = 
%         flag    = 
%     case 'MOGeneticAlgorithm'
%         optCustomOutput = @(options, state, flag) outputFun_GA(options, state, flag, ...
%                                                                BLADE,CAV,ENV,OPT,SIM,TURB,WTP);   
%         options = 
%         state   = 
%         flag    = 
%     otherwise
%         
% end

%% Run the optimization
switch OPT.ALG
    case 'GradientSearch';     [OPT.xBest, OPT.fval, OPT.exitflag, OPT.output]                                =       fmincon(OPT.objective, OPT.x0,      OPT.Aineq, OPT.bineq, [], [], OPT.lb, OPT.ub, [], OPT.options); 
    case 'PatternSearch';      [OPT.xBest, OPT.fval, OPT.exitflag, OPT.output]                                = patternsearch(OPT.objective, OPT.x0,      OPT.Aineq, OPT.bineq, [], [], OPT.lb, OPT.ub, [], OPT.options);
    case 'ParticleSwarm';      [OPT.xBest, OPT.fval, OPT.exitflag, OPT.output, OPT.finalPop, OPT.finalScores] =           pso(OPT.objective, OPT.numVars, OPT.Aineq, OPT.bineq, [], [], OPT.lb, OPT.ub, [], OPT.options);     
    case 'GeneticAlgorithm';   [OPT.xBest, OPT.fval, OPT.exitFlag, OPT.output, OPT.finalPop, OPT.finalScores] =            ga(OPT.objective, OPT.numVars, OPT.Aineq, OPT.bineq, [], [], OPT.lb, OPT.ub, [], OPT.options);
    case 'MOGeneticAlgorithm'; [OPT.xBest, OPT.fval, OPT.exitFlag, OPT.output, OPT.finalPop, OPT.finalScores] =    gamultiobj(OPT.objective, OPT.numVars, OPT.Aineq, OPT.bineq, [], [], OPT.lb, OPT.ub,     OPT.options); 
    otherwise
        error('ERROR: Unrecognized value for OPT.ALG');
end

%% postProcessing
HARP_Opt_PostProcess(BLADE,CAV,ENV,OPT,SIM,TURB,WTP);

%% Final clean-up
fprintf(1, ['HARP_Opt version ' SIM.version ' terminated normally for case ' SIM.tag '.\n']);
diary OFF
fclose all;
close all;

end % function HARP_Opt
