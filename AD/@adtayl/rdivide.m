function y = rdivide(x,y)
% Division x./y for adtayl objects.
% Error checking : it assumes that if X or Y is not a adtayl
% then it is a (scalar) numeric object.
if ~isa(y,'adtayl') %assume Y is a number
  ydup = y; y = x;
  y.tc = x.tc ./ ydup;
elseif ~isa(x,'adtayl') %assume X is a number
  [m,n,p] = size(y.tc);
  mn = m*n;
  y.tc = reshape(y.tc,mn,p);
  for i=1:mn
    y.tc(i,:) = filter(x, y.tc(i,:), [1 zeros(1,p-1)]);
  end
  y.tc = reshape(y.tc,m,n,p);
else
  if ~isequal(size(x),size(y)) %adtayl size, just the [m n] dimensions
    error('Arguments must have equal sizes')
  end
  [m,n,p] = size(y.tc);
  mn = m*n;
  x.tc = reshape(x.tc,mn,p);
  y.tc = reshape(y.tc,mn,p);
  for i=1:mn
    y.tc(i,:) = filter(x.tc(i,:), y.tc(i,:), [1 zeros(1,p-1)]);
  end
  y.tc = reshape(y.tc,m,n,p);
end
