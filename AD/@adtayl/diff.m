function x = diff(x)
% Differentiate Taylor series.
% [x_0, x_1, ..., x_p] becomes [x_1, 2*x_2, ..., p*x_p, 0]
[m,n,p1] = size(x.tc);
p = p1-1;
x.tc = reshape(x.tc,m*n,p1);
x.tc = [x.tc(:,2:end).*repmat(1:p,m*n,1), zeros(m*n,1)];
x.tc = reshape(x.tc,m,n,p1);
