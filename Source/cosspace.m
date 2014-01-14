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

function x = cosspace(x1, x2, N, flag)
%if flag = 'start', half cosing spacing, points are packed more dense at the beginning
%if flag = 'end',   half cosing spacing, points are packed more dense at the end
%if flag = 'both',  full cosing spacing, points are packed more dense at the beginning AND end


L = x2 - x1;

switch flag
    case 'start'
        t = linspace(pi,pi/2,N)';
        x = x1 + L.*(1 + cos(t));
    case 'end'
        t = linspace(pi/2,0,N)';
        x = x1 + L.*cos(t);
    case 'both'
        t = linspace(pi,0,N)';
        x = x1 + L.*(1 + cos(t))./2;
end

x(1)   = x1;    % fixes rounding errors from floating point
x(end) = x2;    % fixes rounding errors from floating point

end % function cosspace
