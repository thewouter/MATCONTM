function x = sin(x)
% SIN for adtayl objects.

global adtayl_CSSAV adtayl_CSARG

if ~isreal(x.tc)
  error('COS, SIN for adtayl objects must not have imaginary part')
end

% Compute and store COS and SIN together; or check to see if already
% computed.
if isequal(x.tc, adtayl_CSARG)
  x.tc = adtayl_CSSAV;
else
  adtayl_CSARG = x.tc;
  x = exp(i*x); % a adtayl object
  adtayl_CSSAV = x.tc; % a complex array
end
x.tc = imag(x.tc);
