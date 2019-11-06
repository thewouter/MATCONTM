function c = vertcat(varargin)
%VERTCAT  Implements [a(1) ; a(2) ; ...] for adtayl objects

  a = varargin{1};
  c = a;
  for i=2:length(varargin)
    a = varargin{i};
    c.tc = [ c.tc ; a.tc ];
  end
