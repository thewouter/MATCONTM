function j=mjacp(x,p,n)
global fpmds cds
if cds.options.SymDerivativeP >=10
   jj = feval(fpmds.JacobianP, 0, x, p{:});
   jj = jj(:,fpmds.ActiveParams);
   AA=jj;
   for s=1:n-1
      x=feval(fpmds.func,0,x,p{:});
      jj1 = feval(fpmds.JacobianP, 0, x, p{:});
      jj1 = jj1(:,fpmds.ActiveParams); 
      AA=(mjac(x,p,1))*AA+jj1;
   end
   j=AA;
else
    for i=fpmds.ActiveParams
      p1 = p; p1{i} = p1{i}-cds.options.Increment;
      p2 = p; p2{i} = p2{i}+cds.options.Increment;
      x1=x;x2=x;
       for m=1:n     
          x1= feval(fpmds.func, 0, x1, p1{:});
          x2= feval(fpmds.func, 0, x2, p2{:});
       end
       jt(:,i) = x2-x1;
       j = jt/(2*cds.options.Increment);
    end    
    j=j(:,fpmds.ActiveParams);
end
    
