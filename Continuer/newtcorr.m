function [x,v,i] = newtcorr(x0, v0)
%
% Newton corrections, internal routine
%
global cds

x = x0;
v = v0;

R = []; R(cds.ndim,1) = 1;
for i = 1:cds.options.MaxCorrIters
  if i <= cds.options.MaxNewtonIters
    B = [contjac(x); v'];
  end
  % repeat twice with same jacobian, calculating
  % the jacobian is usually a lot more expensive
  % than solving a system
  for t=1:2
    Q = [feval(cds.curve_func, x); 0];

    if isnan(norm(Q)) || isinf(norm(Q))
      x = [];
      v = [];
      return;
    end
    if cds.options.MoorePenrose
      lastwarn('');
      D = B\[Q R];
      if ~isempty(lastwarn)
        x = [];
        v = [];
        return;
      end

      v = D(:,2);
      v = v/norm(v);
      dx = D(:,1);
    else
      dx = B\Q;
    end
    x = x - dx;
%     [norm(dx) norm(Q)]
    if norm(dx) < cds.options.VarTolerance && norm(Q) < cds.options.FunTolerance
      v = ([contjac(x);v']\R);
      v = v/norm(v);
      return;
    end
  end
end

x = [];
v = [];

