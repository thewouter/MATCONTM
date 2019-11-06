function atcs=tcs(a)
% TCS(A) for an ADTAYL object extracts the Taylor coefficient (TC) array a.tc
% If m and n are both >1 it is returned in its raw form as an m by n by p
% Matlab array. But if either is 1, it is returned as an ordinary matrix (or
% row vector if m=n=1), by "squeezing" out a singleton dimension.
atcs = squeeze(a.tc);
