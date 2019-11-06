function x = asech(x)
% asech for adtayl objects.


[m,n,p] = size(x.tc);

for i=1:m   
    for j=1:n
    x1.tc= reshape(x.tc(i,j,:),[1, 1,p]); 
    x1=class(struct('tc',x1.tc),'adtayl');
    asech0 = asech(x1.tc(1,1));
    xx=-x1*(x1+1)*((1-x1)/(1+x1)).^0.5;
    xy=reshape(xx.tc,1,p);
    dx1 = x1.tc(:,2:end).*(1:p-1);       
    y = filter( 1,xy,dx1)./(1:p-1);
    xx1.tc(i,j,:)=[asech0 y]; 
    end
 end

x.tc = reshape(xx1.tc, m,n,p);