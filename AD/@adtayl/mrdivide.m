function x = mrdivide(x,y)
% Division x/y for ADTAYL objects, ONLY for case where Y is a scalar
% (number or ADTAYL).

if ~(numel(y)==1)
  error('X/Y for ADTAYL objects currently requires Y scalar')
end
% We now have 3 cases:
% 1.  (ADTAYL array)/(numeric scalar)
% 2.  (numeric array)     /(ADTAYL scalar)
% 3.  (ADTAYL array)/(ADTAYL scalar)
if ~isa(y,'adtayl') %assume Y is a number so Case 1.
  x.tc = x.tc / y;
elseif ~isa(x,'adtayl') %assume X is a numeric array so Case 2.
  p1 = size(y.tc,3);
  xdup = x;  x=y; %to make X a ADTAYL
  x.tc = zeros([size(xdup) p1]); %give it the 3rd dimension
  x.tc(:,:,1) = xdup; %now we've reduced it to Case 3.
  xy=reshape(y.tc,1,p1);
  x.tc = filter(1, xy, x.tc, [],3); %work along 3rd dimension of x.tc
else %both ADTAYLs so Case 3.
  p1 = size(y.tc,3);
  xy=reshape(y.tc,1,p1);  
  x.tc = filter(1, xy, x.tc, [],3); %work along 3rd dimension of x.tc
end
