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

function [y, poly] = cubicFit(x1, x2, f1, f2, dfdx1, dfdx2, X)

A = [3*x1^2   2*x1    1     0;
    x1^3     x1^2    x1    1;
    3*x2^2   2*x2    1     0;
    x2^3     x2^2    x2    1];
b = [dfdx1; f1; dfdx2; f2];
poly = A\b;

y = poly(1)*X.^3 + poly(2)*X.^2 + poly(3)*X + poly(4);
