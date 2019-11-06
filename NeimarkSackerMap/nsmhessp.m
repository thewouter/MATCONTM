function h=nsmhessp(x,p,n)

global nsmds cds
  if (cds.options.SymDerivative >=2) &&(n==1)
     h = feval(nsmds.HessiansP, 0, x, p{:});
     h = h(:,:,nsmds.ActiveParams);
  else
     
   for i=nsmds.ActiveParams
     p1 = p; p1{i} = p1{i}-cds.options.Increment;
     p2 = p; p2{i} = p2{i}+cds.options.Increment;
     h(:,:,i) = nsmjac(x,p2,n)-nsmjac(x,p1,n);
   end
    h = h(:,:,nsmds.ActiveParams)/(2*cds.options.Increment);
   
 end

