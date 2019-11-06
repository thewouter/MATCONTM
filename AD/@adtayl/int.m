function x = int(x,c)
% Integrate Taylor series, setting the constant of integration to c.
% If c is omitted it is taken as zero.
% [x_0, x_1, ..., x_p] becomes [c, (x_0)/1, (x_1)/2, ..., (x_{p-1})/p]
if nargin<2, c=0; end
if ~isnumeric(c)
  error('Argument c must be numeric (scalar or array)')
end
if ~(isscalar(c) | isequal(size(x),size(c)))
  error('Argument c must be scalar or same size as x')
end
[m,n,p1] = size(x.tc);
p = p1-1;
x.tc = reshape(x.tc,m*n,p1);
x.tc(:,2:end) = x.tc(:,1:end-1)./repmat(1:p,m*n,1);
x.tc(:,1) = c;
x.tc = reshape(x.tc,m,n,p1);
