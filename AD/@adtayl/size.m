function [m,n] = size(x)
% Size of adtayl object.
% It comprises the lengths of the dimensions *excluding* the Taylor
% coefficient dimension.
siz = size(x.tc);
if nargout<=1
  m = siz(1:end-1);
elseif nargout==2
  m = siz(1); n = siz(2);
else
  error('Call with >2 outputs not allowed for adtayl size')
end
