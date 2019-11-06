function x= log(x)
% LOG(X) for  ADTAYL object

[m,n,p1] = size(x.tc);
p = p1-1;
mn = m*n;
x.tc = reshape(x.tc, mn,p1);
log0 = log(x.tc(:,1));
%log0 = log(x.tc(1,1));
for i=1:mn
  dx = x.tc(i,2:end).*(1:p);
  y = filter( 1, x.tc(i,:), dx)./(1:p);
  x.tc(i,:)=[log0(i) y];  
end 
x.tc = reshape(x.tc, m,n,p1);


