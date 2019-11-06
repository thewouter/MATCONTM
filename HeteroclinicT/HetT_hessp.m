function h=HetT_hessp(x,p,J)
global hetTds cds

if (cds.options.SymDerivativeP >= 2)&&(J==1)
  h = feval(hetTds.HessiansP, 0, x, p{:});
  h = h(:,:,hetTds.ActiveParams);
else
  for i=hetTds.ActiveParams
    p1 = p; p1{i} = p1{i}-cds.options.Increment;
    p2 = p; p2{i} = p2{i}+cds.options.Increment;
    h(:,:,i) = hetjac(x,p2,J)-hetjac(x,p1,J);
  end
  h = h(:,:,hetTds.ActiveParams)/(2*cds.options.Increment);
end
