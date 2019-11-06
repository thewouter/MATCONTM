function disp(X)
% Display ADTAYL object.
% Recall, internally it is an (m by n by p1) array, regarded as an m by n
% array of Taylor series to order p where p1=p+1, and with the coefficients
% along the "p1" dimension. Most common use is probably when regarded as a
% column vector, i.e. n=1. So display it as n slices of size m by p1.
[m,n,p1] = size(X.tc);
p = p1-1;
for j=1:n
  if n>1, fprintf(1,' Column %i,',j); end
  fprintf(1,' Coefficients of orders 0 to %i are:\n',p);
  disp(reshape(X.tc(:,j,:),[m p1]))
end
