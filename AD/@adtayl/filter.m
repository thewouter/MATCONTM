function filter.m
% This is just a place to document what I understand about MATLAB's FILTER
% function. Let a polynomial or truncated power-series be stored as a list
% of coefficients a_0, a_1, ..., a_p in that order in a vector of length
% p+1. From the power-series viewpoint, Y = FILTER(A,B,X) can just be
% thought of as doing
%            (polynomial A)
%        Y = -------------- * (array of polynomials X)
%            (polynomial B)
% expanding the resulting power series to same order as X, so that Y and X
% have the same size.
%
% If only they explained that in their documentation!
