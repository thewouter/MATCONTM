function x = cosh(x)
% Coshx for adtayl objects.


if ~isreal(x.tc)
  error('X for adtayl objects must not have imaginary part')
end

 x = 1/2*(exp(x)+exp(-x)); % a adtayl object
 x.tc =x.tc;