function a = subsref(a,s)
% Subscripted reference for ADTAYL objects.
% The only ones allowed are of form A(I) and A(I,J).
% We need to follow Matlab's standard rules for single-subscripting A(I) of
% matrices. Let TC=A.TC have shape [m,n,p]. The complication is that the
% returned TC must always have 3rd dimension p.
%   Index I          Result       Result
%                    contents     shape
%   --------------------------------------
%      :             all TC       [:,1,p]
%   col, k by 1      TC(I,1,:)    [:,1,p]
%   row, 1 by k      TC(I,1,:)    [1,:,p]    note contents same as previous
%
%   Index I,J        Result       Result
%                    contents     shape
%   --------------------------------------
%   numel(I)=k,
%   numel(J)=l       TC(I,J,:)    [k,l,p]
%
% Note S.SUBS is {I} or {I,J}.

[m,n,p] = size(a.tc);
switch s.type
  case '()'
    switch numel(s.subs)
      case 1 %The A(I) case
        a.tc = reshape(a.tc, [],1,p);
        i = s.subs{1};
        if isequal(i,':')    %whole array as column
          return
        elseif size(i,2)==1  %I is a column
          a.tc = a.tc(i,1,:);
        else                 %I is a row
          a.tc = reshape(a.tc(i,1,:), 1,[],p);
        end
      case 2 %The A(I,J) case
        % Pass indices to TC field, with : appended. From 'doc subsref'!
        a.tc = a.tc(s.subs{:},:);
    end
  otherwise
    error('Wrong kind of subscripting for ADTAYL object')
end
