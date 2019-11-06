function obj =  adtayl(a, p)
% Constructor for ADTAYL class.
% An ADTAYL object has one field TC. In the scalar case, TC is a row
% vector of length (p+1) holding the coefficients x_0, x_1, ... x_p of the
% Taylor series (TS) of a variable x =x(t) around a point a, in order from
% array position 1 to p+1. That is, setting t = a+s,
%   x(t) = x(a+s) = x_0 + x_1 s + x_2 s^2 + ... + x_p s^p +
%                                    + (higher order terms)             (1)
%
% One cannot create a general series (1) directly. ADTAYL can be used in these
% two ways:
% T = ADTAYL(A,P) creates the TS of the independent variable t expanded about
% a, that is
%   t = a + 1 s + 0 s^2 + ... + 0 s^p
% stored as the array [a, 1, 0, ..., 0]. All other functions must be
% calculated from that. For instance
%      T = ADTAYL(0.5,3); Y = 1/T;                                      (2)
% forms the TS of t around t=0.5 to order 3, stored as the array [0.5, 1,
% 0, 0], and then the TS of y=1/t around the same point to the same order,
% namely y(0.5+s) = 2 - 4s + 8s^2 - 16s^3, stored  as [2, -4, 8, -16].
%
% The order, p, is stored in a global variable so that subsequent creation of
% constant-functions gets the order right.
%
% C = ADTAYL(CVAL) creates a constant-function, *after* the independent
% variable has been created. CVAL can be a (numeric) scalar or a 1 or 2
% dimensional array. C is of the same shape, and of the currently stored
% order, representing CVAL + 0 s + ... + 0 s^p.
% E.g. after (2) is done, C = ADTAYL([2;5],'const') creates an ADTAYL
% column vector of length 2 with
%   C(1) = 2 + 0 s + ... + 0 s^p,
%   C(2) = 5 + 0 s + ... + 0 s^p.
%
% ADTAYL's of the same order can be assembled into larger arrays using square
% brackets in the usual way, e.g [T Y; 1+T Y*Y] creates a 2 by 2 matrix of
% Taylor series. Higher-dimensional arrays are NOT supported.
% Internally, an M by N object is an (M by N by P) array, the series always
% being along the last dimension.
%
% ADTAYL's of different orders can exist at the same time, but there will be
% an error if you try to combine, e.g. add, them.

global ADTAYLORDER
switch nargin
  case 0 %Not documented: system can use it for anonymous initialising.
    if isempty(ADTAYLORDER)
      error('Invalid use of ADTAYL constructor: no order p was set')
    else
      tc = zeros(1,1,ADTAYLORDER+1);
    end
  case 1
    if isa(a,'adtayl') %Not documented: just copies an ADTAYL object
      obj = a;
      return
    elseif ~(isnumeric(a) && ndims(a)==2) || isempty(ADTAYLORDER)
      error('Wrong use of ADTAYL constructor with one argument')
    else %Set a constant
      [m,n] = size(a); % A is now a constant scalar or array
      p = ADTAYLORDER;
      tc = reshape([a(:); zeros(m*n*p,1)], [m,n,p+1]);
    end
  case 2
    if ~(isnumeric(p) && isnumeric(a) ...
        && isscalar(a) && isscalar(p) && p==fix(p) && p>=0)
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
  otherwise
    error('Wrong number of arguments to ADTAYL')
end

obj = class(struct('tc',tc),'adtayl');
