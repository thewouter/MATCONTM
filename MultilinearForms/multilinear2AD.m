function ytayl2 = multilinear2AD(func,q1,q2,x0,p1,n) 

%----------------------------------------------------
% This file computes  B^(n)*q1*q2 using automatic differentiation, where 
%B^(n) is the second order derivatives  of map f^(n). 
%----------------------------------------------------
 taylorder=2;

   if q1==q2
    if isreal(q1)
        y1=Bvv(func,x0,q1,p1,taylorder,n);
    else
       y1_1=Bvv(func,x0,real(q1),p1,taylorder,n);
       y1_2=Bvv(func,x0,imag(q1),p1,taylorder,n);       
       y1_3 = multilinear2AD(func,real(q1),imag(q1),x0,p1,n)/2;       
       y = transf(y1_3,taylorder);

       y1 = y1_1-y1_2+2*i*y;       
    end

  else
    if isreal(q1) && isreal(q2)
        y11=Bvv(func,x0,q1+q2,p1,taylorder,n);
        y12=Bvv(func,x0,q1-q2,p1,taylorder,n);
        y1=1/4.0*(y11-y12);
    elseif isreal(q1)                
        y1_1 = multilinear2AD(func,q1,real(q2),x0,p1,n)/2;   
        y1_2 = multilinear2AD(func,q1,imag(q2),x0,p1,n)/2;         
        y1 = transf(y1_1,taylorder);
        y2 = transf(y1_2,taylorder);
        y1 = y1 + i*y2;        
    elseif isreal(q2)
        y1_1 = multilinear2AD(func,real(q1),q2,x0,p1,n)/2;   
        y1_2 = multilinear2AD(func,imag(q1),q2,x0,p1,n)/2;      
        y1 = transf(y1_1,taylorder);
        y2 = transf(y1_2,taylorder);
        y1 = y1 + i*y2;                     
    else        
        y1_1 = multilinear2AD(func,real(q1),real(q2),x0,p1,n)/2;   
        y1_2 = multilinear2AD(func,imag(q1),imag(q2),x0,p1,n)/2;                         
        y1_3 = multilinear2AD(func,imag(q1),real(q2),x0,p1,n)/2;   
        y1_4 = multilinear2AD(func,real(q1),imag(q2),x0,p1,n)/2;         
        y1 = transf(y1_1,taylorder);
        y2 = transf(y1_2,taylorder);
        y3 = transf(y1_3,taylorder);
        y4 = transf(y1_4,taylorder);
        y1 = y1 - y2+i*(y3+y4);                              
    end
   end
  if size(x0,1) >1
ytayl2=2*tcs(y1);
  else
      ytayl2=tcs(y1);
      ytayl2=2*ytayl2(3,:);
  end
%--------------------------------------------------
function y1 = Bvv(mapsf,x0,hc,p1,taylorder,n)
   % Convert to "active" variables:
   s = adtayl(0,taylorder);%Base point & Taylor order
   y1= x0 + s.*hc;
 for i=1:n       
     y1 = mapsf(0, y1,p1{:});
 end

%--------------------------------------------------
function y = transf(v,taylorder)

t = adtayl(0,taylorder);      
y = adtayl(0);
for k = 1:(size(v,1)-1)
    t = [t;t(1,:)];    
    y = [y;y(1,:)];    
end
y = y+v(:,1);
for l = 2:size(v,2)       
    y = y + v(:,l).*t^(l-1);    
end    








