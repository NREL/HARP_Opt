function OPT = guessOptimalClCd(OPT,TURB,AF)
OPT.guess.tsr  = 4*pi/TURB.NUM_BLADES;                      % make a guess at the optimal tip speed ratio
[OPT.guess.L_D OPT.guess.designL_D_ind] = max(AF.maxL_D);   % why are we picking the maximum l/d across all reynolds numbers instead of the Reynolds number at which the blade OPT.objectivections?
OPT.guess.Cl   = AF.maxCl_AoA(OPT.guess.designL_D_ind);
OPT.guess.aoa  = AF.maxL_D_AoA(OPT.guess.designL_D_ind) * pi/180;