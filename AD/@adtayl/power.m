function x = power(x,y)
% X^Y for ADTAYL objects.
% X is an ADTAYL or numeric array. If it is numeric, Y must be ADTAYL (for
% this function to be called at all), and then X is converted to a constant
% ADTAYL of the same size.
% Y is an numeric scalar, or an ADTAYL array. In the latter case, X
% and Y must have the same Taylor order, and either they have the same size,
% or one is scalar.
% When Y is an integer numeric scalar, the power is found by repeated
% multiplication, if Y>0; and by reciprocation and repeated multiplication, if
% Y<0; and is the constant 1 ADTAYL array, if Y=0.
% If it is a non-integer numeric scalar, it is converted to an ADTAYL.
% In this case, and when X, Y are both ADTAYLs (of same size), the formula X^Y
% = exp(Y*log(X)) is used, elementwise.

% We don't check at present that X, Y are either ADTAYL or numeric.
if ~isa(x,'adtayl'), x = adtayl(x); end
if ~isa(y,'adtayl')
  if ~(isnumeric(y) && numel(y)==1)
    error('Y must be ADTAYL or numeric scalar');
  end
  if fix(y)==y % Y is an integer scalar:
    x=powerin(x,y);
    return
  else % Y is a non-integer scalar, convert to constant ADTAYL:
    y = adtayl(y);
  end
end
% Both are now ADTAYLs:
if order(x)~=order(y)
  error('Arguments X and Y have different Taylor orders')
end
[m,n] = size(x);
[my,ny] = size(y);
if ~( (m==my && n==ny) || m*n==1 || my*ny==1)
  error('X and Y must be of same size or one must be a scalar');
end
ind = find(x.tc(:,:,1)==0);
if any(ind)
  error('Some entry in X has zero constant term: cannot raise to noninteger power');
end
x=exp(y.*log(x));

