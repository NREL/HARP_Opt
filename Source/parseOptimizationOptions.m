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

function options = parseOptimizationOptions(optFile)

fid = fopen(optFile, 'r');
if fid == -1; 
    error(['ERROR: Could not locate and open file ' [SIM.rootDir filesep SIM.optOptions]]); 
end

% skip past the header section of the file (can have variable length)
reading = true;
while reading
    temp    = fgetl(fid);
    reading = ~strncmpi(temp, '<startMatlabInput>', 18);
end

% read and execute the text following Matlab syntax
temp1   = [];
temp2   = [];
reading = true;
while reading
    temp1 = fgetl(fid);
    if temp1 == -1; % reached end of file
        reading = false;
    end    
    temp2 = cat(2,temp2,temp1);
end

evalc(temp2);

fclose(fid);

