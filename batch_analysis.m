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
%% ====================================================================== %
% User Parameters: add the cases to include in HARP_Opt batch analysis.
% ======================================================================= %

% cases = {'test_FSFP.inp'};
% cases = {'test_VSVP-F.inp'};

% cases = {'test_FSFP.inp', ...
%          'test_VSFP.inp', ...
%          'test_VSFP_fixedTSR.inp', ...
%          'test_FSVP-F.inp', ...
%          'test_VSVP-F.inp', ...
%          'test_VSVP-S.inp'};

cases = {'test_FSFP_MOGA.inp', ...
         'test_VSVP-F_MOGA.inp'};         

% cases = {'test_FSFP.inp', ...
%          'test_VSFP.inp', ...
%          'test_VSFP_fixedTSR.inp', ...
%          'test_FSVP-F.inp', ...
%          'test_VSVP-F.inp', ...
%          'test_VSVP-S.inp', ...
%          'test_FSFP_MOGA.inp', ...
%          'test_VSVP-F_MOGA.inp'};

%% Setup parallel computing stuff
% runParallel = false;
% numProc     = 4;
% if runParallel
%     poolSize = matlabpool('size');  % check to see if a pool is already open
%     if poolSize == 0 || poolSize < numProc
%         matlabpool close force local
%         eval(['matlabpool open ' num2str(numProc)])
%     end
% else
%     matlabpool close force local
% end

numCases = numel(cases);
% parfor n = 1:numCases; % launch parallel, can we run a separate HARP_Opt instance in each process?
for n = 1:numCases
    % let's have a good clean start each time
%     clearvars -EXCEPT cases numCases n
    close all;
    fclose all;
    diary off;
    clc;

    % run the case
    HARP_Opt(cases{n});   
end

