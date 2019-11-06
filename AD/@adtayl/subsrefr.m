function c = subsref(a,s)
% Subscripted reference for SIMPLEADTAYL objects.
%
%   example   c = a(:,3:5)

% Adapted from Rump's code in INTLAB (which probably is adapted from
% somewhere else...)
% The indexing is supposed to exclude the Taylor coefficient dimension.

while 1
  if ~isa(a,'simpleadtayl')             % for a.tc(i) etc.
    c = subsref(a,s(1));
  elseif strcmp(s(1).type,'()')     % index reference a(i,j)
    switch numel(s(1).subs)
      case 1, c.tc = a.tc(s(1).subs{:},1,:);
      case 2, c.tc = a.tc(s(1).subs{:},:);
      otherwise %give no access to Taylor-coefficient dimension
        error('invalid index reference for simpleadtayl')
    end
    c = class(c,'simpleadtayl');
  elseif strcmp(s(1).type,'.')     % subfield access
    if strcmp(s(1).subs,'tc')
      c=a.tc;
    else
      error('invalid subfield reference for simpleadtayl')
    end
  else
    error('invalid index reference for simpleadtayl')
  end
  if length(s)==1
    return
  end
  s = s(2:end);
  a = c;
end
