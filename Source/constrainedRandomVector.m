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

function X = constrainedRandomVector(popsize,LB,UB,A,b)

% LB <= x <= UB
% A*x <= b

LB = LB(:); % make sure column vectors
UB = UB(:);

X = zeros(numel(LB), popsize);

nAttempts = 0;
nFound    = 0;
while nFound < popsize
   
    nAttempts = nAttempts + 1;
    
    x = LB + rand*(UB - LB);
    if all(A*x <= b)
        % feasible
        nFound = nFound + 1;
        X(:,nFound) = x;
    end
    
end


