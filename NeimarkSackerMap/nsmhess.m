function h=nsmhess(x,p,n)
global nsmds cds
 if (cds.options.SymDerivative >=2) && (n==1)
    h = feval(nsmds.Hessians, 0, x, p{:});
 else
      
   for i=1:nsmds.nphase
     x1 = x; x1(i) = x1(i)-cds.options.Increment;
     x2 = x; x2(i) = x2(i)+cds.options.Increment; 
     h(:,:,i) = nsmjac(x2,p,n)-nsmjac(x1,p,n);
   end
     h = h/(2*cds.options.Increment);   
      
 end

