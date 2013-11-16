function writeOupFileXLS(SIM,OPT,TURB,BLADE,ENV,WTP,WTPoup)

headerLines = 5;

switch OPT.AERO
    case 'eff'
        xlwrite(SIM.xlsfile, {'AEP, annual energy production = ', 'N/A'}, 2,  'A1:B1');
        xlwrite(SIM.xlsfile, {'CF, capacity factor = '          , 'N/A'}, 2,  'A2:B2');
    case 'AEP'
        AEP = calcAEP(WTPoup.vel, WTPoup.power, ENV.FLOW_DIST, ENV.VEL_DIST);
        CF  = AEP/(8760*TURB.RATED_PWR);
        xlwrite(SIM.xlsfile, {'AEP = ', sprintf('%6.6e',AEP)    , '(kW-hrs/year)'}, 2,  'A1:C1');
        xlwrite(SIM.xlsfile, {'CF  = ', sprintf('%6.2f',100*CF) , '(%)'          }, 2,  'A2:C2');
end

geomVar  = {'station'        , 'r/R'    , 'Radius'   , 'Pre-Twist', 'Chord'      , '% Thick'      , 'Thickness', 'Airfoil'};
geomUnit = {'(-)'            , '(-)'    , '(m)'      , '(deg)'    , '(m)'        , '(100*t/c)'    , '(m)'      , '(-)'};
geomData = {[(1:WTP.NUM_SEG)', BLADE.r_R, BLADE.R_ELM, BLADE.twist, BLADE.chord  , BLADE.perThick , BLADE.dimThick]};

xlwrite(SIM.xlsfile, geomVar           , 2,  'A4:H4');
xlwrite(SIM.xlsfile, geomUnit          , 2,  'A5:H5');        
xlwrite(SIM.xlsfile, geomData{:}       , 2, ['A6:G' num2str(headerLines + WTP.NUM_SEG)]);
foils = cellstr(BLADE.afCoefFiles);
for n = 1:WTP.NUM_SEG
    xlwrite(SIM.xlsfile, foils(n), 2, ['H' num2str(headerLines + n)]);
end
%%
perfVar  = {'Flow Spd' , 'TSR'     , 'RotorSpeed', 'Pitch'     , 'Power'     , 'Torque'      , 'Thrust'     , 'FlapMoment'  , 'Cp'     , 'Cq'     , 'Cav'     ,'Converge'      };
perfUnit = {'(m/s)'    , '(-)'     , '(rpm)'     , '(deg)'     , '(kW)'      , '(kN-m)'      , '(kN)'       , '(kN-m)'      , '(-)'    , '(-)'    , '(-)'     ,'(-)'           };
perfData = {[WTPoup.vel, WTPoup.tsr,  WTPoup.rpm , WTPoup.pitch, WTPoup.power,  WTPoup.torque, WTPoup.thrust, WTPoup.flapMom, WTPoup.Cp, WTPoup.Cq, WTPoup.cav, WTPoup.converge]};
xlwrite(SIM.xlsfile, perfVar        , 2,  'J4:U4');
xlwrite(SIM.xlsfile, perfUnit       , 2,  'J5:U5');        
xlwrite(SIM.xlsfile, perfData{:}    , 2, ['J6:U' num2str(headerLines + ENV.NUM_CASES)]);

end

