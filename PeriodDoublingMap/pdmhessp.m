function h=pdmhessp(x,p)
global pdmds cds
  if (cds.options.SymDerivative >=2)
     h = feval(pdmds.HessiansP, 0, x, p{:});
     h = h(:,:,pdmds.ActiveParams);
  else
   for i=pdmds.ActiveParams
     p1 = p; p1{i} = p1{i}-cds.options.Increment;
     p2 = p; p2{i} = p2{i}+cds.options.Increment;
     h(:,:,i) = pdmjac(x,p2,1)-pdmjac(x,p1,1);
   end
  h = h(:,:,pdmds.ActiveParams)/(2*cds.options.Increment);
  end

