function a =  simpleadtayl(a, p)
% Constructor for adtayl class.
% A adtayl object has one field TC.  In the scalar case, TC is a row
% vector of length (p+1) holding the coefficients x_0, x_1, ... x_p of the
% Taylor series (TS) of a variable x =x(t) around a point a, in order from
% array position 1 to p+1. That is, setting t = a+s,
%   x(t) = x(a+s) = x_0 + x_1 s + x_2 s^2 + ... + x_p s^p +
%                                    + (higher order terms)             (1)
%
% One cannot create a general series (1) directly. adtayl creates the
% TS of the independent variable t, that is
%   t = a + 1 s + 0 s^2 + ... + 0 s^p
% and all other functions must be calculated from that. For instance
%      T = adtayl(0.5,3); Y = 1/T;                                (2)
% forms the TS of t around t=0.5 to order 3, stored as the array [0.5, 1,
% 0, 0], and then the TS of y=1/t around the same point to the same order,
% namely y(0.5+s) = 2 - 4s + 8s^2 - 16s^3, stored  as [2, -4, 8, -16].
%
% One can create constant-functions if required, *after* creating the
% independent variable. E.g. after (2) is done,
%     CSERIES = adtayl(C, 'CONST');
% sets C to the adtayl object representing C + 0 s + ... + 0 s^p,
% where p comes from the current (most recently created) independent
% variable. C can be scalar or a 1 or 2 dimensional array.
%
% adtayl's can be M by N matrices of Taylor series, created using square
% brackets in the usual way, e.g [T Y; 1+T Y*Y] creates a 2 by 2 matrix of
% Taylor series. Higher-dimensional arrays are NOT supported.
% Internally storage is as an (M by N by P) array, the series always being
% along the last dimension.

global ADTAYLORDER
if isnumeric(p)
  if ~(isnumeric(a) && isscalar(a) && isscalar(p) && p==fix(p) && p>=0)
    error('Invalid input A or P to construct independent variable')
  else
    % Store chosen Taylor order as a global variable:
    ADTAYLORDER = p;
    if p==0
      tc = a;
    else
      tc = [a, 1, zeros(1,p-1)];
    end
    tc = reshape(tc, [1 1 p+1]);
  end
elseif ischar(p)
  if ~strcmp(lower(p),'const')
    p
    error('Invalid string argument P')
  else
    [m,n] = size(a); % A is now the constant scalar or array
    p = ADTAYLORDER;
    tc = [a(:); zeros(m*n*p,1)];
    tc = reshape(tc, [m,n, p+1]);
  end
end

a = class(struct('tc',tc),'adtayl');
