function x= log10(x)
% LOG10(X) for  adtayl object

[m,n,p1] = size(x.tc);
p = p1-1;
xx=log(x)/log(10);
x.tc = reshape(xx.tc, m,n,p1);







