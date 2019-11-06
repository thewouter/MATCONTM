function h=Het_hessp(x,p,J)
global hetds cds

if (cds.options.SymDerivativeP >= 2)&&(J==1)
  h = feval(hetds.HessiansP, 0, x, p{:});
  h = h(:,:,hetds.ActiveParams);
else
  for i=hetds.ActiveParams
    p1 = p; p1{i} = p1{i}-cds.options.Increment;
    p2 = p; p2{i} = p2{i}+cds.options.Increment;
    h(:,:,i) = hetjac(x,p2,J)-hetjac(x,p1,J);
  end
  h = h(:,:,hetds.ActiveParams)/(2*cds.options.Increment);
end
