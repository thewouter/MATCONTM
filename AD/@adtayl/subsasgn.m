function a = subsasgn(a,s,b)
% Subscripted reference for ADTAYL objects.
% The only ones allowed are of form A(I) and A(I,J).
%
% This should allow ':' as a subscript but doesn't, yet.
switch s.type
  case '()'
    if ~isa(b,'adtayl')
      error('Incompatible left & right sides for assignment')
    else
      % Pass indices to TC field, with : appended.
      a.tc(s.subs{:},:) = b.tc;
    end
  otherwise
    error('Wrong kind of subscripting for ADTAYL object')
end
