function j=homjacp(x,p,n)
global homds cds

if cds.options.SymDerivativeP >=1
  jj = feval(homds.JacobianP, 0, x, p{:});
  jj = jj(:,homds.ActiveParams);
  AA=jj;
  for s=1:n-1
    x=feval(homds.func,0,x,p{:});
    jj1 = feval(homds.JacobianP, 0, x, p{:});
    jj1 = jj1(:,homds.ActiveParams); 
    AA=(homjac(x,p,1))*AA+jj1;
  end
  j=AA;
else
  for i=homds.ActiveParams
    p1 = p; p1{i} = p1{i}-cds.options.Increment;
    p2 = p; p2{i} = p2{i}+cds.options.Increment;
    x1=x;x2=x;
    for m=1:n     
      x1 = feval(homds.func, 0, x1, p1{:});
      x2 = feval(homds.func, 0, x2, p2{:});
    end
    jt(:,i) = x2-x1;
    j = jt/(2*cds.options.Increment);
  end    
  j=j(:,homds.ActiveParams);
end