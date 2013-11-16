function [f, BLADE, WTP, WTPoup] = optAero(x0,SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state)

% Get the blade geometry and airfoil files
[BLADE.chord, BLADE.twist, BLADE.perThick, BLADE.dimThick, BLADE.cps] = getBladeGeom(x0,OPT,BLADE,TURB);
BLADE.afCoefFiles = strcat(BLADE.FOIL_FAM,'_',num2str(10.*BLADE.perThick,'%04.0f'),'.dat');
BLADE.foilFileStr = cellstr( strcat('"Airfoil_Data',filesep,BLADE.afCoefFiles,'"') );  

%% Configure the WT_Perf cases
switch TURB.CONTROL
    case 'FSFP'
         
        WTP.NUM_CASES   = ENV.NUM_CASES;
        WTP.spd         = ENV.VEL; 
        WTP.rotSpd      = x0(end) .* ones(WTP.NUM_CASES, 1);
        WTP.pitch       = zeros(WTP.NUM_CASES, 1);
        WTPoup          = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
        
    case 'VSFP'
        
        WTP.NUM_CASES   = ENV.NUM_CASES;
        WTP.spd         = ENV.VEL; 
        WTP.rotSpd      = optRotorSpeeds(x0(end),TURB,ENV);
        WTP.pitch       = zeros(WTP.NUM_CASES, 1);
        WTPoup          = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
             
        if any(WTPoup.power >= TURB.RATED_PWR) % need to control rotor speed in region 3 to reduce power
            if strcmp(state,'final')
                WTP.rotSpd = find_rpm(WTPoup,state,WTP,SIM,TURB,CAV,ENV,BLADE);
                WTPoup     = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
            else
                % to save time, don't bother finding the actual rotor
                % speeds yet, for now just overwrite any values exceeding
                % rated power, optimum rotor speeds can be found in final
                % iteration
                WTPoup.power(WTPoup.power > TURB.RATED_PWR) = TURB.RATED_PWR;
            end
        end
               
    case {'FSVP_F','FSVP_S'}
        
        WTP.NUM_CASES   = ENV.NUM_CASES;
        WTP.spd         = ENV.VEL; 
        WTP.rotSpd      = x0(end) .* ones(WTP.NUM_CASES, 1);
        WTP.pitch       = zeros(WTP.NUM_CASES, 1);
        WTPoup          = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
                
        if any(WTPoup.power >= TURB.RATED_PWR) % need to pitch the blades in region 3 to reduce power
            if strcmp(state,'final')
                % need to find the actual pitch angles, either because this is the final solution, or 
                % for hydrokinetic turbines need to find the actual pitch angles to check for cavitation
                WTP.pitch = find_pitch(WTPoup,'reg3',state,WTP,SIM,TURB,CAV,ENV,BLADE);
                WTPoup    = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
            else
                % to save time, don't bother finding the actual pitch
                % angles yet, for now just overwrite any values exceeding
                % rated power, optimum pitch angles can be found in final
                % iteration
                WTPoup.power(WTPoup.power > TURB.RATED_PWR) = TURB.RATED_PWR;
            end
        end
                
    case {'VSVP_F','VSVP_S'}      
        WTP.NUM_CASES   = ENV.NUM_CASES;
        WTP.spd         = ENV.VEL; 
        WTP.rotSpd      = optRotorSpeeds(x0(end),TURB,ENV);
        WTP.pitch       = zeros(WTP.NUM_CASES, 1);
        WTPoup          = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
                
        if any(WTPoup.power >= TURB.RATED_PWR) % need to pitch the blades in region 3 to reduce power
            
            % find the flow speeds for region 3 (where power is above rated power and pitch will vary to shed excess power & loads)
            i_reg3 = find(WTPoup.power > TURB.RATED_PWR, 1);
            V_reg3 = WTPoup.vel(i_reg3:end);
            
            WTP.rotSpd(i_reg3:end) = WTPoup.rpm(i_reg3);
            WTPoup = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
            
            if CAV.CAVITATION || strcmp(state,'final')
                % need to find the actual pitch angles, either because this is the final solution, or 
                % for hydrokinetic turbines need to find the actual pitch angles to check for cavitation
                WTP.pitch = find_pitch(WTPoup,'reg3',state,WTP,SIM,TURB,CAV,ENV,BLADE);
                WTPoup    = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
            else
                % to save time, don't bother finding the actual pitch angles yet, for now just overwrite any values exceeding rated power, optimum pitch angles can be found in post-processing
                WTPoup.power(WTPoup.power > TURB.RATED_PWR) = TURB.RATED_PWR;
            end
        end
        
        if TURB.LOWSPD_VP && strcmp(state,'final')
            WTP.pitch = find_pitch(WTPoup,'reg1p5',state,WTP,SIM,TURB,CAV,ENV,BLADE);
            WTPoup    = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);
        end
        
    otherwise
        error('[ERROR] Unrecognized input for TURB.CONTROL');
        
end % switch TURB.CONTROL

%% calculate the fitness value
if CAV.CAVITATION
    penaltyCav = sum(WTPoup.cav)/numel(WTPoup.cav); % the percentage of cases in which cavitation occurs.
else
    penaltyCav = 0;
end
        
switch TURB.CONTROL
    case 'FSFP'
        penaltyPwr = max(max(WTPoup.power./TURB.RATED_PWR), 1); % the magnitude of power exceeding rated power (non-dimensionalized)
        switch OPT.AERO
            case 'eff'
                res = sum( (OPT.pwr_ideal - WTPoup.power).^2 ); % the residual from the ideal WTP.power curve
                f   = res*(penaltyPwr*(1+penaltyCav))^2;
            case 'AEP'
                aep = calcAEP(ENV.VEL, WTPoup.power, ENV.FLOW_DIST, ENV.VEL_DIST);
                f   = -aep*(1/penaltyPwr)*(1-penaltyCav)^2;
        end
        
    case 'VSFP' 
        i_reg3 = ENV.NUM_CASES; % initialize as the last flow speed, in case region 3 does not actually exist
        for m = 2:ENV.NUM_CASES
            if WTPoup.rpm(m) < WTPoup.rpm(m-1)
                i_reg3 = m-1;
                break
            end
        end
        torqueRated = WTPoup.torque(i_reg3);
        torqueMax   = max(WTPoup.torque);
        penaltyTrq  = max(torqueMax/torqueRated, 1);
        penaltyPwr  = max(max(WTPoup.power./TURB.RATED_PWR), 1); % the magnitude of power exceeding rated power (non-dimensionalized)
        
        switch OPT.AERO
            case 'eff'
                res = sum( (OPT.pwr_ideal - WTPoup.power).^2 ); % the residual from the ideal WTP.power curve
                f   = res*(penaltyPwr*penaltyTrq*(1+penaltyCav))^2;
            case 'AEP'
                aep = calcAEP(ENV.VEL, WTPoup.power, ENV.FLOW_DIST, ENV.VEL_DIST);
                f   = -aep*(1/penaltyPwr)*(1/penaltyTrq)*(1-penaltyCav)^2;
        end
        
    case {'FSVP_F','FSVP_S','VSVP_F','VSVP_S'}        
        switch OPT.AERO
            case 'eff'
                res = sum( (OPT.pwr_ideal - WTPoup.power).^2 ); % the residual from the ideal WTP.power curve
                f   = res*(1+penaltyCav)^2;
            case 'AEP'
                aep = calcAEP(ENV.VEL, WTPoup.power, ENV.FLOW_DIST, ENV.VEL_DIST);
                f   = -aep*(1-penaltyCav)^2;
        end
        
end

end % function optAero

function rotSpd = optRotorSpeeds(optTSR,TURB,ENV)
    rotSpd                        = 30.*optTSR.*ENV.VEL./(pi*TURB.ROTOR_RAD);
    rotSpd(rotSpd < TURB.RPM_MIN) = TURB.RPM_MIN;
    rotSpd(rotSpd > TURB.RPM_MAX) = TURB.RPM_MAX;
end % function optRotorSpeeds()

