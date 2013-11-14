function VEL_DIST = getFlowPDF(SIM, ENV)
                          
switch ENV.FLOW_DIST
    case 'Rayleigh'
        VEL_DIST = (pi./2).*(ENV.VEL./ENV.MEAN_RAY.^2).*exp(-(pi./4).*(ENV.VEL./ENV.MEAN_RAY).^2); 
        
    case 'Weibull'
        VEL_DIST = (ENV.K_WBL./ENV.C_WBL).*((ENV.VEL./ENV.C_WBL).^(ENV.K_WBL-1)).*exp(-(ENV.VEL./ENV.C_WBL).^ENV.K_WBL);
                 
    case 'Hist'
        fid = fopen(SIM.flowFile,'r');
        if fid == -1; 
            error(['ERROR: Could not locate and open file ' SIM.flowFile]); 
        end
        data = textscan(fid,'%f %f','HeaderLines',6,'CollectOutput',1);
        data = cell2mat(data);
        fclose(fid);
        VEL_DIST = struct('BIN_CENTERS',   data(:,1),...
                          'FRAC_OCCURNCE', data(:,2));
                      
        % some error checking
        if VEL_DIST.BIN_CENTERS(1) > ENV.SPD_ST || VEL_DIST.BIN_CENTERS(end) < ENV.SPD_ST
            error(['ERROR: The flow speeds defined by ENV.SPD_ST and ENV.SPD_END cannot extend outside the range of speeds listed in file ' SIM.flowFile]); 
        end
        
            
    otherwise
        error('ERROR: Unrecognized value for ENV.FLOW_DIST.')
        
end

if strcmp(ENV.FLOW_DIST,'Hist') 
    %check for proper bounds on flow speeds ENV.SPD_ST, ENV.SPD_END, ENV.SPD_DEL, ENV.VEL_DIST.BIN_CENTERS
    
end
