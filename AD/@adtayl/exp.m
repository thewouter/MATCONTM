function x = exp(x)
% Compute exponential of Taylor series, for each element of adtayl
% array.

% Uses the differential equation y' = x' * y .
% One way to see the method is as follows. Let T be the linear operator
%              / t
%   (Ty)(t) = |    x'(s) y(s) ds.
%             / 0
% Then the above ODE can be recast in integral form as
%   y = y_0 + Ty    where  y_0 = exp(x(0)) (regarded as a constant function).
% Thus
%   y = (I - T) \ y_0 .
% To reduce the amount of arithmetic this is recast as
%   y = (K - L) \ (K * y_0)
% where K = diag([1, 1:p]), p being the Taylor series order, and L is the
% strictly lower-triangular Toeplitz matrix with first column
%   [0, 1x(1), 2x(2), ..., px(p)].
% This should be fairly fast ... we shall see
[m,n,p1] = size(x.tc);
p = p1-1;
mn = m*n;
x.tc = reshape(x.tc, mn,p1);
exp0 = exp(x.tc(:,1)); %vector of exponentials of constant terms
Kdiag = [1 1:p];
z = zeros(p,1);
for i=1:mn
  % Form derivative of x.tc regarded as Taylor series:
  dx = x.tc(i,2:end).*(1:p); %of length p, not p+1.
  L = toeplitz([0 dx], zeros(1,p1));
  x.tc(i,:) = ((diag(Kdiag) - L) \ [exp0(i);z]).'; %want a row vector as output
end

x.tc = reshape(x.tc, m,n,p1);
