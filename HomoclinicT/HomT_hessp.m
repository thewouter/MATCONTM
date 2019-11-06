function h=HomT_hessp(x,p,J)
global homTds cds

if (cds.options.SymDerivativeP >= 2)&&(J==1)
  h = feval(homTds.HessiansP, 0, x, p{:});
  h = h(:,:,homTds.ActiveParams);
else
  for i=homTds.ActiveParams
    p1 = p; p1{i} = p1{i}-cds.options.Increment;
    p2 = p; p2{i} = p2{i}+cds.options.Increment;
    h(:,:,i) = homT_jac(x,p2,J)-homT_jac(x,p1,J);
  end
  h = h(:,:,homTds.ActiveParams)/(2*cds.options.Increment);
end
