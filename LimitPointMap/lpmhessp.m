function h=lpmhessp(x,p)
global lpmds cds
  if (cds.options.SymDerivative >=2)
     h = feval(lpmds.HessiansP, 0, x, p{:});
     h = h(:,:,lpmds.ActiveParams);
  else
      
  for i=lpmds.ActiveParams
    p1 = p; p1{i} = p1{i}-cds.options.Increment;
    p2 = p; p2{i} = p2{i}+cds.options.Increment;
    h(:,:,i) = lpmjac(x,p2,1)-lpmjac(x,p1,1);
  end
  h = h(:,:,lpmds.ActiveParams)/(2*cds.options.Increment);
  end

