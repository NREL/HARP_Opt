function pitch = find_pitch(WTPoup,region,state,WTP,SIM,TURB,CAV,ENV,BLADE)


% setup an optimization problem
switch region
    case 'reg3'
        maxAngle = TURB.PITCH_MAX_R3;
        
        % find the flow speeds for region 3 (where power is above rated power and pitch will vary to shed excess power & loads)
        i_reg3 = find(WTPoup.power > TURB.RATED_PWR, 1);
        V_reg3 = WTPoup.vel(i_reg3:end);
        spd    = V_reg3;
        i_reg  = i_reg3;

    case 'reg1p5'
        maxAngle = TURB.PITCH_MAX_R1p5;
        
        % find the flow speeds for region 1.5 (where the pitch will be varied to increase efficiency near cut-in)
        % the pitch is variable in region 1.5 (between cut-in and optimal TSR, i.e. at RPM_MIN)
        for n = 1:ENV.NUM_CASES
            if WTPoup.rpm(n) > TURB.RPM_MIN; 
                i_reg2 = n;
                break
            end
        end
        V_reg1p5 = ENV.VEL(1:i_reg2-1);
        spd      = V_reg1p5;
        i_reg    = i_reg2-1;
        
end

options = optimset('Algorithm',              'interior-point', ...
				   'AlwaysHonorConstraints', 'bounds', ...                       
				   'Diagnostics',            'off', ...
				   'Display',                'off', ...             % iter-detailed
				   'FinDiffType',            'central', ...
				   'ScaleProblem',           'obj-and-constr', ...
				   'SubproblemAlgorithm ',   'cg', ...
				   'Hessian',                'bfgs', ... 
				   'UseParallel',            'never', ...
				   'MaxIter',                20, ...
				   'TolX',                   0.01, ...
				   'TolFun',                 1e-3); 

xBest     = 0;
pitch     = WTPoup.pitch;
pitch_opt = zeros(numel(spd), 1);
for n = 1:numel(spd)
        
    if strcmp(TURB.CONTROL,'FSVP_F') || strcmp(TURB.CONTROL,'VSVP_F') || strcmp(region,'reg1p5')
        if TURB.MONO_PITCH
            LB = xBest;
        else
            LB = 0;
        end
        UB  = maxAngle;
        ang = LB:TURB.PITCH_DELTA:UB;
    elseif strcmp(TURB.CONTROL,'FSVP_S') || strcmp(TURB.CONTROL,'VSVP_S')
        LB  = -maxAngle;
        if TURB.MONO_PITCH
            UB = xBest;
        else
            UB = 0;
        end
        ang = UB:-TURB.PITCH_DELTA:LB;  
    else
        error('[ERROR] Unrecognized input in find_pitch.m');
    end
     
    WTP.NUM_CASES   = 1;
    WTP.spd         = spd(n); 
    WTP.rotSpd      = WTPoup.rpm(i_reg);
    FUN             = @(pitch) pitchFitness(pitch,region,state,WTP,SIM,TURB,CAV,ENV,BLADE);
    
    method = 'para';
    switch method % not sure which is more efficient yet, they seem to have similar results and computational effort.  The "opt" method has trouble with solutions near the boundary, and is only about 10-20% faster.
        case 'opt'
            % use an optimization algorithm to find the optimal
            % pitch angles, this could reduce the number of WT_Perf calls
%             xInit        = (LB + UB + xBest)/3;
            xInit         = xBest;
            problem       = createOptimProblem('fmincon','objective',FUN,'x0',xInit,'lb',LB,'ub',UB,'options',options);
            startPts      = CustomStartPointSet(linspace(LB, UB, 4)');    
            [xBest, fval] = run(MultiStart,problem,startPts);
            pitch_opt(n)  = xBest;

        case 'para'
            % this is a "brute force" method, do a parametric sweep through all
            % possible pitch angles
            i_min = 1;
            fit   = zeros(numel(ang),1);
            for k = i_min:numel(ang)
               fit(k) = FUN(ang(k));
            end
            [unused, i_min] = min(fit);
            pitch_opt(n)    = ang(i_min);
            xBest           = pitch_opt(n);
            
            if SIM.DEBUG_LVL > 20
                figure
                plot(ang,fit)
                xlabel('pitch angle (deg)')
                ylabel('fitness value')
            end

    end   

end

switch region
    case 'reg3'
        pitch(i_reg:end) = pitch_opt;
    case 'reg1p5'
        pitch(1:i_reg)   = pitch_opt;
end


end %function find_pitch()

% =============================================================================
function f = pitchFitness(pitch,region,state,WTP,SIM,TURB,CAV,ENV,BLADE)
    
WTP.pitch = pitch;
WTPoup    = wtperf_CC(state,WTP,SIM,TURB,CAV,ENV,BLADE);

switch region
    case 'reg3'
        f = abs(WTPoup.power - TURB.RATED_PWR).^2; %residual from rated power
        
    case 'reg1p5'
        f = -max(WTPoup.power, 0); % in this case we just want to maximize power
end

end % function pitchFitness()