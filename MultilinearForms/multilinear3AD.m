function ytayl3 = multilinear3AD(func,q1,q2,q3,x0,p1,n) 
%
%----------------------------------------------------
% This file computes  C^(n)*q1*q2*q3 using automatic differentiation, where 
%C^(n) is the 3rd order derivatives  of map f^(n). 
%----------------------------------------------------

taylorder=3;
if q1==q2
    if q1==q3   
        if isreal(q1)           
            y1=Bvv(func,x0,q1,p1,taylorder,n);
        else
            y1_1=Bvv(func,x0,real(q1),p1,taylorder,n);%a^3
            y1_2=Bvv(func,x0,imag(q1),p1,taylorder,n);%b^3
            y1_3=multilinear3AD(func,real(q1),imag(q1),imag(q1),x0,p1,n)/6;%ab^2
            y1_4=multilinear3AD(func,real(q1),real(q1),imag(q1),x0,p1,n)/6;%a^2b
            y1_3 = transf(y1_3,taylorder);
            y1_4 = transf(y1_4,taylorder);            
            y1 = y1_1-3*y1_3+i*(3*y1_4-y1_2);
        end
    else        
        if isreal(q1) && isreal(q3)            
           y13=Bvv(func,x0,2*q1+q3,p1,taylorder,n);        
           y23=Bvv(func,x0,2*q1-q3,p1,taylorder,n);       
           y33=Bvv(func,x0,q3,p1,taylorder,n);        
           y43=Bvv(func,x0,-q3,p1,taylorder,n);        
           y1=1/24.0*(y13-y23-y33+y43);
        elseif isreal(q1)
            y1_1 = multilinear3AD(func,q1,q1,real(q3),x0,p1,n)/6;
            y1_2 = multilinear3AD(func,q1,q1,imag(q3),x0,p1,n)/6;
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);  
            y1 = y1_1+i*y1_2;
        elseif isreal(q3)
            y1_1 = multilinear3AD(func,real(q1),real(q1),q3,x0,p1,n)/6;
            y1_2 = multilinear3AD(func,imag(q1),imag(q1),q3,x0,p1,n)/6;
            y1_3 = multilinear3AD(func,real(q1),imag(q1),q3,x0,p1,n)/6;
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);  
            y1_3 = transf(y1_3,taylorder);  
            y1 = y1_1-y1_2+2*i*y1_3;
        else
            %q1=a+ib, q3=c+id
            y1_1 = multilinear3AD(func,real(q1),real(q1),real(q3),x0,p1,n)/6;%a^2c
            y1_2 = multilinear3AD(func,real(q1),imag(q1),imag(q3),x0,p1,n)/6;%abd
            y1_3 = multilinear3AD(func,imag(q1),imag(q1),real(q3),x0,p1,n)/6;%b^2c
            y1_4 = multilinear3AD(func,real(q1),real(q1),imag(q3),x0,p1,n)/6;%a^2d
            y1_5 = multilinear3AD(func,real(q1),imag(q1),real(q3),x0,p1,n)/6;%abc
            y1_6 = multilinear3AD(func,imag(q1),imag(q1),imag(q3),x0,p1,n)/6;%b^2d
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);  
            y1_3 = transf(y1_3,taylorder); 
            y1_4 = transf(y1_4,taylorder);
            y1_5 = transf(y1_5,taylorder);  
            y1_6 = transf(y1_6,taylorder); 
            y1 = y1_1-2*y1_2-y1_3+i*(y1_4+2*y1_5-y1_6);            
        end
    end
else
      if isreal(q1) && isreal(q2) && isreal(q3)
           y123= Bvv(func,x0,q1+q2+q3,p1,taylorder,n);        
           y12m3= Bvv(func,x0,q1+q2-q3,p1,taylorder,n);       
           y1m23= Bvv(func,x0,q1-q2+q3,p1,taylorder,n);         
           y1m2m3= Bvv(func,x0,q1-q2-q3,p1,taylorder,n);       
           y1=1/24.0*(y123-y12m3-y1m23+y1m2m3);
      elseif isreal(q1) && isreal(q2)
          y1_1 = multilinear3AD(func,q1,q2,real(q3),x0,p1,n)/6;
          y1_2 = multilinear3AD(func,q1,q2,imag(q3),x0,p1,n)/6;
          y1_1 = transf(y1_1,taylorder);
          y1_2 = transf(y1_2,taylorder);
          y1 = y1_1+i*y1_2;    
      elseif isreal(q1) && isreal(q3)
          y1_1 = multilinear3AD(func,q1,real(q2),q3,x0,p1,n)/6;
          y1_2 = multilinear3AD(func,q1,imag(q2),q3,x0,p1,n)/6;
          y1_1 = transf(y1_1,taylorder);
          y1_2 = transf(y1_2,taylorder);
          y1 = y1_1+i*y1_2;          
      elseif isreal(q2) && isreal(q3)
          y1_1 = multilinear3AD(func,real(q1),q2,q3,x0,p1,n)/6;
          y1_2 = multilinear3AD(func,imag(q1),q2,q3,x0,p1,n)/6;
          y1_1 = transf(y1_1,taylorder);
          y1_2 = transf(y1_2,taylorder);
          y1 = y1_1+i*y1_2;          
      elseif isreal(q1)
          y1_1 = multilinear3AD(func,q1,real(q2),real(q3),x0,p1,n)/6;
          y1_2 = multilinear3AD(func,q1,imag(q2),imag(q3),x0,p1,n)/6;
          y1_3 = multilinear3AD(func,q1,imag(q2),real(q3),x0,p1,n)/6;
          y1_4 = multilinear3AD(func,q1,real(q2),imag(q3),x0,p1,n)/6;
          y1_1 = transf(y1_1,taylorder);
          y1_2 = transf(y1_2,taylorder);
          y1_3 = transf(y1_3,taylorder); 
          y1_4 = transf(y1_4,taylorder);
          y1 = y1_1-y1_2+i*(y1_3+y1_4);       
      elseif isreal(q2)
          y1_1 = multilinear3AD(func,real(q1),q2,real(q3),x0,p1,n)/6;
          y1_2 = multilinear3AD(func,imag(q1),q2,imag(q3),x0,p1,n)/6;
          y1_3 = multilinear3AD(func,imag(q1),q2,real(q3),x0,p1,n)/6;
          y1_4 = multilinear3AD(func,real(q1),q2,imag(q3),x0,p1,n)/6;
          y1_1 = transf(y1_1,taylorder);
          y1_2 = transf(y1_2,taylorder);
          y1_3 = transf(y1_3,taylorder); 
          y1_4 = transf(y1_4,taylorder);
          y1 = y1_1-y1_2+i*(y1_3+y1_4);          
      elseif isreal(q3)
          y1_1 = multilinear3AD(func,real(q1),real(q2),q3,x0,p1,n)/6;
          y1_2 = multilinear3AD(func,imag(q1),imag(q2),q3,x0,p1,n)/6;
          y1_3 = multilinear3AD(func,imag(q1),real(q2),q3,x0,p1,n)/6;
          y1_4 = multilinear3AD(func,real(q1),imag(q2),q3,x0,p1,n)/6;
          y1_1 = transf(y1_1,taylorder);
          y1_2 = transf(y1_2,taylorder);
          y1_3 = transf(y1_3,taylorder); 
          y1_4 = transf(y1_4,taylorder);
          y1 = y1_1-y1_2+i*(y1_3+y1_4); 
      else
          y1_1 = multilinear3AD(func,real(q1),real(q2),real(q3),x0,p1,n)/6;
          y1_2 = multilinear3AD(func,imag(q1),imag(q2),real(q3),x0,p1,n)/6;
          y1_3 = multilinear3AD(func,imag(q1),real(q2),imag(q3),x0,p1,n)/6;
          y1_4 = multilinear3AD(func,real(q1),imag(q2),imag(q3),x0,p1,n)/6;
          y1_5 = multilinear3AD(func,real(q1),real(q2),imag(q3),x0,p1,n)/6;
          y1_6 = multilinear3AD(func,imag(q1),imag(q2),imag(q3),x0,p1,n)/6;
          y1_7 = multilinear3AD(func,imag(q1),real(q2),real(q3),x0,p1,n)/6;
          y1_8 = multilinear3AD(func,real(q1),imag(q2),real(q3),x0,p1,n)/6;
          y1_1 = transf(y1_1,taylorder);
          y1_2 = transf(y1_2,taylorder);
          y1_3 = transf(y1_3,taylorder); 
          y1_4 = transf(y1_4,taylorder);
          y1_5 = transf(y1_5,taylorder);
          y1_6 = transf(y1_6,taylorder);
          y1_7 = transf(y1_7,taylorder); 
          y1_8 = transf(y1_8,taylorder);
          y1 = y1_1-y1_2-y1_3-y1_4+i*(y1_5-y1_6+y1_7+y1_8); 
      end                             
end 
if size(x0,1) >1
ytayl3=6*tcs(y1);
  else
      ytayl3=tcs(y1);
      ytayl3=6*ytayl3(4,:);
end
%--------------------------------------------------------------------------

function y1 = Bvv(mapsf,x0,hc,p1,taylorder,n)
   
   % Convert to "active" variables:
   s = adtayl(0,taylorder); %Base point & Taylor order
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


