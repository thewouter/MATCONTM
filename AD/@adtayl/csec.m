function x = csec(x)
% SEC for adtayl objects.

if ~isreal(x.tc)
  error('CSEC for adtayl objects must not have imaginary part')
end 

[m,n,p] = size(x.tc);
for i=1:m
    for j=1:n
    x1.tc= reshape(x.tc(i,j,:),[1, 1,p]); 
    x1=class(struct('tc',x1.tc),'adtayl');
    y= sin(x1).^(-1);    
    xx1.tc(i,j,:)=y.tc;
    end   
 end
x.tc = reshape(xx1.tc, m,n,p);