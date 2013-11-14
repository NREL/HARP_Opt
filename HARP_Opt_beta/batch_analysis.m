%% ====================================================================== %
% User Parameters: add the cases to include in HARP_Opt batch analysis.
% ======================================================================= %

%Run a single case.
% cases = {'test_FSFP.inp'};
% cases = {'test_VSVP-F.inp'};
cases = {'test_VSFP_circularRoot.inp'};
% cases = {'test_FSFP_MOGA.inp'};
% cases = {'test_VSVP-F_MOGA.inp'};

%Run multiple cases.
% cases = {'test_FSFP.inp', ...
%          'test_FSVP-F.inp', ...
%          'test_FSVP-S.inp', ...
%          'test_VSFP.inp', ...
%          'test_VSFP_circularRoot.inp', ...
%          'test_VSFP_fixed_TSR.inp', ...
%          'test_VSVP-F.inp', ...
%          'test_VSVP-S.inp'}; 
 
     
%% ====================================================================== %
% Nothing after here should need to be modified.
% ======================================================================= %
clc;

numCases = numel(cases);
% parfor n = 1:numCases launch parallel
for n = 1:numCases
    % let's have a clean start each time
    clearvars -EXCEPT cases numCases n
    close all;
    fclose all;
    diary off

    % run the case
    HARP_Opt(cases{n});
end

