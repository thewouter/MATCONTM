function y = times(x,y)
% Elementwise multiplication x.*y for ADTAYL objects.
% Either of x or y can be numeric, and either can be scalar (1 by 1). If
% neither is scalar, they must have the same size.
% In effect, a numeric argument is converted to ADTAYL, and a scalar argument
% is "spread" to the size of the other.
%
% The method uses the FILTER function. The case when either argument is a
% scalar runs fastest because one can do it with just one call to FILTER.

x = adtayl(x);
y = adtayl(y);
if isscalar(x) % X is a scalar ADTAYL, do a FILTER on all Y at once
  [m,n,p] = size(y.tc);
  mn = m*n;
  x.tc = reshape(x.tc,1,p);
  y.tc = reshape(y.tc,mn,p);
  y.tc = filter(x.tc, 1, y.tc, [],2); %along the 2nd dimension
elseif isscalar(y) % Y is a scalar ADTAYL, do a FILTER on all X at once
  [m,n,p] = size(x.tc);
  mn = m*n;
  x.tc = reshape(x.tc,mn,p);
  y.tc = reshape(y.tc,1,p);
  y.tc = filter(y.tc, 1, x.tc, [],2); %along the 2nd dimension
elseif ~isequal(size(x),size(y)) %ADTAYL size, just the [m n] dimensions
  error('Arguments must have equal sizes')
else
  [m,n,p] = size(x.tc);
  mn = m*n;
  x.tc = reshape(x.tc,mn,p);
  y.tc = reshape(y.tc,mn,p);
  for i=1:mn
    y.tc(i,:) = filter(x.tc(i,:), 1, y.tc(i,:));
  end
end
y.tc = reshape(y.tc,m,n,p);
