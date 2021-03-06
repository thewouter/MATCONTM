function x = acotan(x)
% acotan for adtayl objects.

[m,n,p] = size(x.tc);
for i=1:m
    for j=1:n
    x1.tc= reshape(x.tc(i,j,:),[1, 1,p]); 
    x1=class(struct('tc',x1.tc),'adtayl');
    acotan0 = (pi/2-atan(x1.tc(1,1)));
    xx=-(1+x1*x1);
    xy=reshape(xx.tc,1,p);
    dx1 = x1.tc(:,2:end).*(1:p-1);       
    y = filter( 1,xy,dx1)./(1:p-1);
    xx1.tc(i,j,:)=[acotan0 y]; 
     end
 end
x.tc=xx1.tc;
x.tc=real(x.tc);
x.tc = reshape(xx1.tc, m,n,p);
%%% %%%   %%%%   %%%
