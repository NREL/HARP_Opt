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

function [DEV, OPT, TURB, ENV, BLADE, CAV, WTP] = parseInputFile(inpFile)

fid = fopen(inpFile, 'r');

if fid == -1; 
    error(['ERROR: Could not locate and open file ' inpFile]); 
end

readingInput = 'Reading';
while readingInput == 'Reading'
    temp = fgetl(fid);
    if temp == -1;
        break;
    end
    evalc(temp);
end; 

fclose(fid);