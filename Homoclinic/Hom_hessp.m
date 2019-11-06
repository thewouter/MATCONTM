function h=Hom_hessp(x,p,J)
global homds cds

if (cds.options.SymDerivativeP >= 2)&&(J==1)
  h = feval(homds.HessiansP, 0, x, p{:});
  h = h(:,:,homds.ActiveParams);
else
  for i=homds.ActiveParams
    p1 = p; p1{i} = p1{i}-cds.options.Increment;
    p2 = p; p2{i} = p2{i}+cds.options.Increment;
    h(:,:,i) = homjac(x,p2,J)-homjac(x,p1,J);
  end
  h = h(:,:,homds.ActiveParams)/(2*cds.options.Increment);
end
