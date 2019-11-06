function j=cjacp(mapfile,x,p,ap)
global cds
if cds.options.SymDerivativeP >= 1
  % Use symbolic derivatives if they are defined
  j = feval(odefile, 0, x, 'jacobianp', p{:});
else
  % If not, use finite differences
  if size(ap,1) ~= 1
        ap = ap';
  end
  for i=ap
    p1 = p; p1{i} = p1{i}-cds.options.Increment;
    p2 = p; p2{i} = p2{i}+cds.options.Increment;
    j(:,i) = feval(mapfile, 0, x, p2{:})-feval(mapfile, 0, x, p1{:});
  end
  j = j/(2*cds.options.Increment);
end
j=j(:,ap);
