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

function [state, options, optchanged] = outputFun_custom(options,state,flag, ...
                                                         BLADE,CAV,ENV,OPT,SIM,TURB,WTP)
%GAOUTPUTFCNTEMPLATE Template to write custom OutputFcn for GA.
%   [STATE, OPTIONS, OPTCHANGED] = GAOUTPUTFCNTEMPLATE(OPTIONS,STATE,FLAG)
%   where OPTIONS is an options structure used by GA. 
%
%   STATE: A structure containing the following information about the state 
%   of the optimization:
%             Population: Population in the current generation
%                  Score: Scores of the current population
%             Generation: Current generation number
%              StartTime: Time when GA started 
%               StopFlag: String containing the reason for stopping
%              Selection: Indices of individuals selected for elite,
%                         crossover and mutation
%            Expectation: Expectation for selection of individuals
%                   Best: Vector containing the best score in each generation
%        LastImprovement: Generation at which the last improvement in
%                         fitness value occurred
%    LastImprovementTime: Time at which last improvement occurred
%
%   FLAG: Current state in which OutputFcn is called. Possible values are:
%         init: initialization state 
%         iter: iteration state
%    interrupt: intermediate state
%         done: final state
% 		
%   STATE: Structure containing information about the state of the
%          optimization.
%
%   OPTCHANGED: Boolean indicating if the options have changed.
%
%	See also PATTERNSEARCH, GA, GAOPTIMSET

persistent fig1 

optchanged = false;

switch OPT.STRUCT     
    case {'none'}
        % this was a single objective case
        [best_fval_aero, best_index_aero] = min(state.Score);
        x_best_aero                       = state.Population(best_index_aero,:);
    otherwise
        % this was a multi objective case
        [best_fval_aero  , best_index_aero]   = min(state.Score(:,1));
        [best_fval_struct, best_index_struct] = min(state.Score(:,2));
        x_best_aero                           = state.Population(best_index_aero,:);
        x_best_struct                         = state.Population(best_index_struct,:);
end

%%                                    
switch flag
    case 'init'
        if OPT.PLOT_ITER
            % create the figures
            fig1 = figure('name', 'Current Best Point', ...
                          'color', 'white', ...
                          'units', 'normalized',...
                          'outerposition', [0.1 0.1 0.8 0.8]);
        end
        
    otherwise
        % don't create any plots   
end

if OPT.PLOT_ITER
    switch OPT.STRUCT     
        case {'none'}
            % this was a single objective case
            plotSolution(fig1, x_best_aero, state, BLADE,CAV,ENV,OPT,SIM,TURB,WTP); 
        otherwise
            % this was a multi objective case
            plotSolution(fig1, x_best_aero, state, BLADE,CAV,ENV,OPT,SIM,TURB,WTP);
%             plotSolution(fig1, x_best_struct, state, BLADE,CAV,ENV,OPT,SIM,TURB,WTP);
    end
end

end % function outputFun_custom

function plotSolution(fig, x_current, state, BLADE,CAV,ENV,OPT,SIM,TURB,WTP)

[chord twist perThick dimThick cps] = getBladeGeom(x_current,OPT,BLADE,TURB);
  

%% plot the panel thickness
set(0,'CurrentFigure',fig);
clf

%% plot the blade geometry
subplot(4,2,1); 
hold on;
title('Blade Geometry - Best Solution');
plot(BLADE.R_ELM, twist, '.-r');
plot(cps.twist_cp_x, cps.twist_cp_y, 'ok');
ylabel('pre-twist (deg)');
box on
xlim([0 TURB.ROTOR_RAD]);

subplot(4,2,3);
hold on;
plot(BLADE.R_ELM, chord, '.-r');
plot(cps.chord_cp_x, cps.chord_cp_y, 'ok');
ylabel('chord (m)');
box on
xlim([0 TURB.ROTOR_RAD]);
ylim([0 max(get(gca,'YLim'))]);

subplot(4,2,5);
hold on;
plot(BLADE.R_ELM, dimThick, '.-r');
ylabel('max thickness (m)');
box on
xlim([0 TURB.ROTOR_RAD]);
ylim([0 max(get(gca,'YLim'))]);

subplot(4,2,7);
hold on;
plot(BLADE.R_ELM, perThick, '.-r');
xlabel('rotor radius (m)');
ylabel('max % thickness (%)');
box on
xlim([0 TURB.ROTOR_RAD]);
ylim([0 max(get(gca,'YLim'))]);

subplot(4,2,[2 8]);
hold on;
title(['Pareto Front - Generation = ' num2str(state.Generation)]);
plot(state.Score(:,1), state.Score(:,2), 'or');
xlabel('objective 1 - aerodynamic fitness');
ylabel('objective 2 - structural fitness');
box on

% %% assign the elements of the design vector into meaningful variable names
% % [cp_twist, ...        
% %  cp_chord, ...   
% %  cp_perThick, ...
% %  cp_dimThick, ...
% %  cp_RPM_TSR] = assignDesignVars(x_current, OPT, BLADE, WEB, z_oub, z_CP);
% 
% % % cp_1     = reshape(x_current(1:BLADE.NUM_CP*2), BLADE.NUM_CP, 2);
% % cp_2     = reshape(x_current(1+BLADE.NUM_CP*2:BLADE.NUM_CP*2+BLADE.NUM_FOILS), BLADE.NUM_FOILS, 1);
% % cp_twist = cp_1(:,1);
% % cp_chord = cp_1(:,2);
% % cp_foil  = x_current(end);
% % 
% 
% 
% %     
% 
% 
% % 
% % if OPT.PLOT_GLAUERT
% %     figure; 
% %     
% %     [chord_init twist_init perThick_init dimThick_init cps] = getBladeGeom(OPT.x0,OPT,BLADE,TURB);
% %     
% %     subplot(3,1,1);
% %     hold on;
% %     plot(BLADE.R_ELM,glauert.twist.deg, ':b')
% %     plot(BLADE.R_ELM,twist_init, '.-k')
% %     plot(cps.twist_cp_x, cps.twist_cp_y, 'or')
% %     legend('Glauert','initial guess', 'control points')
% %     ylabel('Airfoil twist (deg)')
% %     axis([0 TURB.ROTOR_RAD get(gca,'YLim')]);
% % 
% %     subplot(3,1,2);
% %     hold on;
% %     plot(BLADE.R_ELM,glauert.c, ':b')
% %     plot(BLADE.R_ELM,chord_init, '.-k')
% %     plot(cps.chord_cp_x, cps.chord_cp_y, 'or')
% %     legend('Glauert','initial guess', 'control points')
% %     ylabel('chord (m)')
% %     axis([0 TURB.ROTOR_RAD 0 max(get(gca,'YLim'))]);
% % 
% %     subplot(3,1,3);
% %     hold on;
% %     plot(BLADE.R_ELM,perThick_init, '.-k')
% %     if BLADE.NUM_FOILS > 1
% %         plot(cps.foil_cp_x, BLADE.FOIL_VALS, 'or')
% %     end
% %     ylabel('thickness 100*(t/c)')
% %     axis([0 TURB.ROTOR_RAD 0 max(get(gca,'YLim'))]);
% % 
% % end

end %function plotSolution

