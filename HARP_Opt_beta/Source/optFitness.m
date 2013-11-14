function f = optFitness(x0,SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state)

%% separate the subsets of design variables
x_aero   = x0;      
% x_struct = x0(?); 

if strcmp(OPT.STRUCT,'none')
    f = zeros(1, 1); % there is only 1 objective
else
    f = zeros(2, 1); % there are 2 objectives
end

%% single objective
[f(1), BLADE, WTP, WTPoup] = optAero(x_aero,    SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state);
% f = f_aero:
% f = fstruct / f_aero;
% f = f_aero:

%% multiple objective
switch OPT.STRUCT
    case 'CoBlade'
        % derives some kind of structural objective from CoBlade
%         f_struct = optStruct(WTPoup);
%         f(2) = f_struct;

        % create a Co-Blade input file
        % harpOpt2coBlade(SIM.inpFile) this refers to a CoBlade input file

        % now run a CoBlade parametric analysis

        % read the output files

        % assign the structural fitness function

        
    case 'WT_Perf'
        % derives some kind of structural objective from WT_Perf
        f_struct = optStruct(WTPoup);
        f(2) = f_struct;
        
    case 'none'
        return
        
    otherwise
        
end



