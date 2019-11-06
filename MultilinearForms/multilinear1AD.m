function ytayl1 = multilinear1AD(func,q1,x0,p1,n) 

%----------------------------------------------------
% This file computes  A^(n)*q1 using automatic differentiation, where A^(n) is the Jacobian 
% of the map f^(n). 
%----------------------------------------------------

taylorder=1;
if isreal(q1)
    y1=Bvv(func,x0,q1,p1,taylorder,n);
else
    y1_1=Bvv(func,x0,real(q1),p1,taylorder,n);
    y1_2=Bvv(func,x0,imag(q1),p1,taylorder,n);
    y1 = y1_1+i*y1_2;
end
if size(x0,1) >1
ytayl1=tcs(y1);
  else
      ytayl1=tcs(y1);
      ytayl1=ytayl1(2,:);
end
%---------------------------------------------
function y1= Bvv(mapsf,x0,hc,p1,taylorder,n)
   
   % Convert to "active" variables:
   s = adtayl(0,taylorder);%Base point & Taylor order
   y1= x0 + s.*hc;
   for i=1:n     
     y1 = mapsf(0, y1,p1{:});
   end
   



