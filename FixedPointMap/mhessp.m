function h=mhessp(x,p)
global fpmds cds
  if (cds.options.SymDerivative >=2)
       h = feval(fpmds.HessiansP, 0, x, p{:});
       h = h(:,:,fpmds.ActiveParams);  
  else
     for i=fpmds.ActiveParams
       p1 = p; p1{i} = p1{i}-cds.options.Increment; 
       p2 = p; p2{i} = p2{i}+cds.options.Increment;
       h(:,:,i) = mjac(x,p2,1)-mjac(x,p1,1);
     end
    h = h(:,:,fpmds.ActiveParams)/(2*cds.options.Increment);
  end
  
