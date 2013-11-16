function [y, poly] = cubicFit(x1, x2, f1, f2, dfdx1, dfdx2, X)

A = [3*x1^2   2*x1    1     0;
    x1^3     x1^2    x1    1;
    3*x2^2   2*x2    1     0;
    x2^3     x2^2    x2    1];
b = [dfdx1; f1; dfdx2; f2];
poly = A\b;

y = poly(1)*X.^3 + poly(2)*X.^2 + poly(3)*X + poly(4);
