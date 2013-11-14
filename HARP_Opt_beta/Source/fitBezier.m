function yCP = fitBezier(xGlauert,yGlauert,xCP,A,b,lb,ub)
% This function determined the initial chord length control points that are
% passed to the optimization function. The control points are determined by
% minimizing the error between the glauert optimal blade and the blade used
% to seed the optimization algorithim. The residual is determined by
% comparing the coordinates of the glauert optimal blade with the
% bezier-fit to the blade control points, thus allowing for a circular
% rooted blade to be compared to the glauert optimal blade.
%
% @author: Danny Sale and Michael Lawson
% @date: July, 25 2012


% Set the optimization options
Options = optimset('Algorithm',   'interior-point', ...  
                   'Diagnostics', 'off', ...
                   'Display',     'off', ...              
                   'FinDiffType', 'central', ...
                   'UseParallel', 'always', ...
                   'MaxIter',     100, ...
                   'TolX',        1e-6, ...
                   'PlotFcns',    []);

% Initial guess for chord length control points
yCPo = linspace(yGlauert(1),yGlauert(end),numel(xCP))';

% Definition of the optimization function
FUN  = @(yCP) curveResidual(xCP,yCP,xGlauert,yGlauert);

% Run the optimization
yCP  = fmincon(FUN,yCPo,A,b,[],[],lb,ub,[],Options);

end 


function r = curveResidual(xCP,yCP,x,y)
% This function computes the residual between the Glauert optimal solution
% and the interpolated bezier blade shape

% Interpolate the blade shape around the control points
yi = interp1Bez(xCP, yCP, x);

% Compute the residual between the bezier curve and the Glauert blade
r  = sum( (y-yi).^2 );

end 