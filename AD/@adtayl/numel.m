function a = numel(x)
% Number of elements in ADTAYL object.
% See documentation of the builtin NUMEL for why this is important.
% It is the product of the lengths of the dimensions *excluding* the Taylor
% coefficient dimension.
siz = size(x.tc);
a = prod(siz(1:end-1));
