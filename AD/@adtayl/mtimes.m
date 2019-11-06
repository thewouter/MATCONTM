function y = mtimes(x,y)
% Multiply ADTAYL objects.

if ~(isscalar(x) || isscalar(y))
  error('Matrix multiply of ADTAYL objects not supported')
end
y = times(x,y);
