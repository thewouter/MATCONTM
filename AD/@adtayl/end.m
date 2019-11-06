function ind=end(a,k,n)
switch n
  case 1 %Single subscripting A(I), treat it as m*n by p
    [m,n,p] = size(a.tc);
    ind = m*n;
  case 2
    ind = size(a.tc,k);
  otherwise
    error('Wrong use of END in subscript')
end
