function y = plus(x,y)
% Addition of ADTAYL objects.
% Either of x or y can be numeric, and either can be scalar (1 by 1). If
% neither is scalar, they must have the same size.
% In effect, a numeric argument is converted to ADTAYL, and a scalar argument
% is "spread" to the size of the other.

x = adtayl(x);
y = adtayl(y);
if isscalar(x)
  [m,n,p] = size(y.tc);
  x.tc = repmat(x.tc,m,n);
elseif isscalar(y)
  [m,n,p] = size(x.tc);
  y.tc = repmat(y.tc,m,n);
end
y.tc = x.tc + y.tc;
