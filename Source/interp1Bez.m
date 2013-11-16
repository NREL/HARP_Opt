function [yi xB yB] = interp1Bez(xCP, yCP, xi, nPts, method)

if nargin < 5
    method = 'linear';
end
if nargin < 4
    nPts = 100;
end

t = linspace(0,1,nPts);
n = numel(xCP);

X      = zeros(n, n);
Y      = zeros(n, n);
X(:,1) = xCP;
Y(:,1) = yCP;
xB     = zeros(nPts, 1);
yB     = zeros(nPts, 1);
for j = 1:nPts
    for i = 2:n
        X(i:n,i) = (1-t(j))*X(i-1:n-1,i-1) + t(j)*X(i:n,i-1);
        Y(i:n,i) = (1-t(j))*Y(i-1:n-1,i-1) + t(j)*Y(i:n,i-1);
    end
    xB(j) = X(n,n);
    yB(j) = Y(n,n);
end

% xB and yB should form a single valued function for the interpolation step to work correctly
dx = xB(2:end) - xB(1:end-1);
if any(dx < 0)
    error('Error: xB and yB do not form a single valued function, cannot interpolate.');
end

yi = interp1(xB, yB, xi, method);

end % function interp1Bez
