function AEP = calcAEP(VEL,pwr,FLOW_DIST,VEL_DIST)
                                     
switch FLOW_DIST      
    case 'Hist'
        % VEL_DIST contains data for a histogram, use method of bins   
        % interpolate the power curve to the midpoints of the histogram bins
        midptPwr  = interp1q(VEL, pwr, VEL_DIST.BIN_CENTERS);
        midptPwr(isnan(midptPwr)) = 0; %overwrite any NAN values that were extrapolated
        AEP       = sum(8760.*VEL_DIST.FRAC_OCCURNCE.*midptPwr); %(kW-hrs/year)
        
    otherwise
        % VEL_DIST contains data for a probability distribution function
        avgPwr    = trapzf(VEL, pwr.*VEL_DIST);
        AEP       = avgPwr*8760; %(kW-hrs/year)

end



