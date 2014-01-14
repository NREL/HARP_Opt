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

function WTPoup = readOutFileWTPerf(SIM,WTP,analysisWTP)

outFile = [SIM.outputDir filesep SIM.caseName '.oup'];
fid = fopen(outFile,'r');
if fid == -1
    error(['ERROR: Could not locate and open file ' outFile]);
end

switch analysisWTP
    case 'cc'
        % skip the header lines
        for n = 1:7
            fgetl(fid);
        end

        data = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %q %q');
        WTPoup.vel      = data{:,1};
        WTPoup.tsr      = data{:,2};
        WTPoup.rpm      = data{:,3};
        WTPoup.pitch    = data{:,4};
        WTPoup.power    = data{:,5};
        WTPoup.torque   = data{:,6};
        WTPoup.thrust   = data{:,7};
        WTPoup.flapMom  = data{:,8};
        WTPoup.Cp       = data{:,9};
        WTPoup.Cq       = data{:,10};
        WTPoup.cav      = true_false(data{:,11});
        WTPoup.converge = true_false(data{:,12});
        
    case 'para'
        % skip the header lines
        for n = 1:14
            fgetl(fid);
        end
        numCol = numel(WTP.pitSt:WTP.pitDel:WTP.pitEnd);
        data   = textscan(fid, repmat('%f ', 1, numCol+1));
        WTPoup.vel  = data{:,1};
        WTPoup.data = cell2mat( data(:,2:numCol+1) );
end

fclose(fid);

% overwrite any negative values that would be non-physical
WTPoup.power(WTPoup.power < 0)     = 0;
WTPoup.Cp(WTPoup.Cp < 0)           = 0;
WTPoup.torque(WTPoup.torque < 0)   = 0;
WTPoup.thrust(WTPoup.thrust < 0)   = 0;
WTPoup.flapMom(WTPoup.flapMom < 0) = 0;
WTPoup.Cq(WTPoup.Cq < 0)           = 0;

end % function readOutFileWTPerf

function tf = true_false(string)
% converts a string to a logical (i.e. true/false)
N  = size(string,1);
tf = false(N, 1);
for n = 1:N
    str = lower(string{n});

    switch str
        case 't'
            tf(n) = true;
        case 'f'
            tf(n) = false;
    end
end
end % function true_false
