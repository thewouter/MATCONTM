function x = sinh(x)
% Sinhx for adtayl objects.


if ~isreal(x.tc)
  error('X for adtayl objects must not have imaginary part')
end

 x = 1/2*(exp(x)-exp(-x)); % a adtayl object
 