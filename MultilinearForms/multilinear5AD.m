function ytayl5 = multilinear5AD(func,q1,q2,q3,q4,q5,x0,p1,n) 
%
%----------------------------------------------------
% This file computes  E^(n)*q1*q2*q3*q4*q5 using automatic differentiation, where 
%C^(n) is the 5th order derivatives  of map f^(n). 
%----------------------------------------------------


taylorder=5;

if (q1==q2 & q1 ==q3)
    if (q1==q4 & q1==q5)
        if isreal(q1)
            y1 = Bvv(func,x0,q1,p1,taylorder,n);
        else
            y1_1 = Bvv(func,x0,real(q1),p1,taylorder,n);            
            y1_2 = multilinear5AD(func,real(q1),real(q1),real(q1),imag(q1),imag(q1),x0,p1,n)/120;            
            y1_3 = multilinear5AD(func,real(q1),imag(q1),imag(q1),imag(q1),imag(q1),x0,p1,n)/120;            
            y1_4 = multilinear5AD(func,real(q1),real(q1),real(q1),real(q1),imag(q1),x0,p1,n)/120;            
            y1_5 = multilinear5AD(func,real(q1),real(q1),imag(q1),imag(q1),imag(q1),x0,p1,n)/120;            
            y1_6 = Bvv(func,x0,imag(q1),p1,taylorder,n);         
            y1_2 = transf(y1_2,taylorder);            
            y1_3 = transf(y1_3,taylorder);             
            y1_4 = transf(y1_4,taylorder);            
            y1_5 = transf(y1_5,taylorder);            
            y1 = y1_1-10*y1_2+5*y1_3+i*(5*y1_4-10*y1_5+y1_6); 
        end
    else

        if isreal(q1) && isreal(q4) && isreal(q5)        
            y16 = Bvv(func,x0,3.0*q1+q4+q5,p1,taylorder,n);                                          
            y26 = Bvv(func,x0,3.0*q1+q4-q5,p1,taylorder,n);                    
            y36 = Bvv(func,x0,3.0*q1-q4-q5,p1,taylorder,n);                                          
            y46 = Bvv(func,x0,3.0*q1-q4+q5,p1,taylorder,n);            
            y56 = Bvv(func,x0,q1+q4+q5,p1,taylorder,n);            
            y66 = Bvv(func,x0,q1+q4-q5,p1,taylorder,n);            
            y76 = Bvv(func,x0,q1-q4-q5,p1,taylorder,n);            
            y86 = Bvv(func,x0,q1-q4+q5,p1,taylorder,n);            
            y96 = Bvv(func,x0,-q1+q4+q5,p1,taylorder,n);            
            y106 = Bvv(func,x0,-q1+q4-q5,p1,taylorder,n);            
            y116 = Bvv(func,x0,-q1-q4-q5,p1,taylorder,n);            
            y126 = Bvv(func,x0,-q1-q4+q5,p1,taylorder,n);                        
            y1 = (y16 - y26 +y36 -y46 - 2.0*y56 +2.0*y66-2.0*y76+2.0*y86+y96-y106+y116-y126)/1920.0;
        elseif isreal(q1) && isreal(q4)
            y1_1 = multilinear5AD(func,q1,q1,q1,q4,real(q5),x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,q1,q1,q1,q4,imag(q5),x0,p1,n)/120;     
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1 = y1_1+i*y1_2;            
        elseif isreal(q1) && isreal(q5)
            y1_1 = multilinear5AD(func,q1,q1,q1,real(q4),q5,x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,q1,q1,q1,imag(q4),q5,x0,p1,n)/120;     
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1 = y1_1+i*y1_2; 
        elseif isreal(q4) && isreal(q5)
            y1_1 = multilinear5AD(func,real(q1),real(q1),real(q1),q4,q5,x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,real(q1),imag(q1),imag(q1),q4,q5,x0,p1,n)/120;     
            y1_3 = multilinear5AD(func,real(q1),real(q1),imag(q1),q4,q5,x0,p1,n)/120;            
            y1_4 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),q4,q5,x0,p1,n)/120;     
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);             
            y1_4 = transf(y1_4,taylorder);
            y1 = y1_1-3*y1_2+i*(3*y1_3-y1_4);
        elseif isreal(q1)
            y1_1 = multilinear5AD(func,q1,q1,q1,real(q4),real(q5),x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,q1,q1,q1,imag(q4),imag(q5),x0,p1,n)/120;     
            y1_3 = multilinear5AD(func,q1,q1,q1,real(q4),imag(q5),x0,p1,n)/120;            
            y1_4 = multilinear5AD(func,q1,q1,q1,imag(q4),real(q5),x0,p1,n)/120;     
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);             
            y1_4 = transf(y1_4,taylorder);
            y1 = y1_1-y1_2+i*(y1_3+y1_4);           
        elseif isreal(q4)
            y1_1 = multilinear5AD(func,real(q1),real(q1),real(q1),q4,real(q5),x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,real(q1),imag(q1),imag(q1),q4,real(q5),x0,p1,n)/120;     
            y1_3 = multilinear5AD(func,real(q1),real(q1),imag(q1),q4,imag(q5),x0,p1,n)/120;            
            y1_4 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),q4,imag(q5),x0,p1,n)/120;     
            y1_5 = multilinear5AD(func,real(q1),real(q1),real(q1),q4,imag(q5),x0,p1,n)/120;            
            y1_6 = multilinear5AD(func,real(q1),imag(q1),imag(q1),q4,imag(q5),x0,p1,n)/120;     
            y1_7 = multilinear5AD(func,real(q1),real(q1),imag(q1),q4,real(q5),x0,p1,n)/120;            
            y1_8 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),q4,real(q5),x0,p1,n)/120;
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);             
            y1_4 = transf(y1_4,taylorder);
            y1_5 = transf(y1_5,taylorder);
            y1_6 = transf(y1_6,taylorder);
            y1_7 = transf(y1_7,taylorder);             
            y1_8 = transf(y1_8,taylorder);
            y1 = y1_1-3*y1_2-3*y1_3+y1_4+i*(y1_5-3*y1_6+3*y1_7-y1_8);
        elseif isreal(q5)
            y1_1 = multilinear5AD(func,real(q1),real(q1),real(q1),real(q4),q5,x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,real(q1),imag(q1),imag(q1),real(q4),q5,x0,p1,n)/120;     
            y1_3 = multilinear5AD(func,real(q1),real(q1),imag(q1),imag(q4),q5,x0,p1,n)/120;            
            y1_4 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),imag(q4),q5,x0,p1,n)/120;     
            y1_5 = multilinear5AD(func,real(q1),real(q1),real(q1),imag(q4),q5,x0,p1,n)/120;            
            y1_6 = multilinear5AD(func,real(q1),imag(q1),imag(q1),imag(q4),q5,x0,p1,n)/120;     
            y1_7 = multilinear5AD(func,real(q1),real(q1),imag(q1),real(q4),q5,x0,p1,n)/120;            
            y1_8 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),real(q4),q5,x0,p1,n)/120;
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);             
            y1_4 = transf(y1_4,taylorder);
            y1_5 = transf(y1_5,taylorder);
            y1_6 = transf(y1_6,taylorder);
            y1_7 = transf(y1_7,taylorder);             
            y1_8 = transf(y1_8,taylorder);
            y1 = y1_1-3*y1_2-3*y1_3+y1_4+i*(y1_5-3*y1_6+3*y1_7-y1_8); 
        else
            y1_1 = multilinear5AD(func,real(q1),real(q1),real(q1),real(q4),real(q5),x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,real(q1),real(q1),real(q1),imag(q4),imag(q5),x0,p1,n)/120;     
            y1_3 = multilinear5AD(func,real(q1),imag(q1),imag(q1),real(q4),real(q5),x0,p1,n)/120;            
            y1_4 = multilinear5AD(func,real(q1),imag(q1),imag(q1),imag(q4),imag(q5),x0,p1,n)/120;     
            y1_5 = multilinear5AD(func,real(q1),real(q1),imag(q1),real(q4),imag(q5),x0,p1,n)/120;            
            y1_6 = multilinear5AD(func,real(q1),real(q1),imag(q1),imag(q4),real(q5),x0,p1,n)/120;     
            y1_7 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),real(q4),imag(q5),x0,p1,n)/120;            
            y1_8 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),imag(q4),real(q5),x0,p1,n)/120;            
            y1_9 = multilinear5AD(func,real(q1),real(q1),real(q1),real(q4),imag(q5),x0,p1,n)/120;            
            y1_10 = multilinear5AD(func,real(q1),real(q1),real(q1),imag(q4),real(q5),x0,p1,n)/120;     
            y1_11 = multilinear5AD(func,real(q1),imag(q1),imag(q1),real(q4),imag(q5),x0,p1,n)/120;            
            y1_12 = multilinear5AD(func,real(q1),imag(q1),imag(q1),imag(q4),real(q5),x0,p1,n)/120;     
            y1_13 = multilinear5AD(func,real(q1),real(q1),imag(q1),real(q4),real(q5),x0,p1,n)/120;            
            y1_14 = multilinear5AD(func,real(q1),real(q1),imag(q1),imag(q4),imag(q5),x0,p1,n)/120;     
            y1_15 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),real(q4),real(q5),x0,p1,n)/120;            
            y1_16 = multilinear5AD(func,imag(q1),imag(q1),imag(q1),imag(q4),imag(q5),x0,p1,n)/120;
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);             
            y1_4 = transf(y1_4,taylorder);
            y1_5 = transf(y1_5,taylorder);
            y1_6 = transf(y1_6,taylorder);
            y1_7 = transf(y1_7,taylorder);             
            y1_8 = transf(y1_8,taylorder);
            y1_9 = transf(y1_9,taylorder);
            y1_10 = transf(y1_10,taylorder);
            y1_11 = transf(y1_11,taylorder);             
            y1_12 = transf(y1_12,taylorder);
            y1_13 = transf(y1_13,taylorder);
            y1_14 = transf(y1_14,taylorder);
            y1_15 = transf(y1_15,taylorder);             
            y1_16 = transf(y1_16,taylorder);
            y1 = y1_1-y1_2-3*y1_3+3*y1_4-3*y1_5-3*y1_6+y1_7+y1_8+i*(y1_9+y1_10-3*y1_11-3*y1_12+3*y1_13-3*y1_14-y1_15+y1_16); 
        end
    end

else
    if isreal(q1) && isreal(q2) && isreal(q3) && isreal(q4) && isreal(q5)        
         y18 =Bvv(func,x0,q1+q2+q3+q4+q5,p1,taylorder,n);            
         y28 = Bvv(func,x0,q1+q2+q3+q4-q5,p1,taylorder,n);        
         y38 = Bvv(func,x0,q1+q2+q3-q4-q5,p1,taylorder,n);        
         y48 = Bvv(func,x0,q1+q2+q3-q4+q5,p1,taylorder,n);              
         y58 = Bvv(func,x0,q1+q2-q3+q4+q5,p1,taylorder,n);       
         y68 = Bvv(func,x0,q1+q2-q3+q4-q5,p1,taylorder,n);        
         y78 = Bvv(func,x0,q1+q2-q3-q4-q5,p1,taylorder,n);        
         y88 = Bvv(func,x0,q1+q2-q3-q4+q5,p1,taylorder,n);        
         y1= (y18 - y28 + y38 - y48 - y58 + y68 - y78 + y88)/1920.0;        
         y18 =  Bvv(func,x0,q1-q2+q3+q4+q5,p1,taylorder,n);        
         y28 =  Bvv(func,x0,q1-q2+q3+q4-q5,p1,taylorder,n);        
         y38 =  Bvv(func,x0,q1-q2+q3-q4-q5,p1,taylorder,n);       
         y48 =  Bvv(func,x0,q1-q2+q3-q4+q5,p1,taylorder,n);        
         y58 =  Bvv(func,x0,q1-q2-q3+q4+q5,p1,taylorder,n);        
         y68 = Bvv(func,x0,q1-q2-q3+q4-q5,p1,taylorder,n);        
         y78 =  Bvv(func,x0,q1-q2-q3-q4-q5,p1,taylorder,n);        
         y88 = Bvv(func,x0,q1-q2-q3-q4+q5,p1,taylorder,n);      
         y1 = y1 +(-y18 +y28 - y38 + y48 + y58 - y68 + y78 - y88)/1920.0;
    else 
            y1_1 = multilinear5AD(func,real(q1),real(q2),real(q3),real(q4),real(q5),x0,p1,n)/120;            
            y1_2 = multilinear5AD(func,imag(q1),imag(q2),real(q3),real(q4),real(q5),x0,p1,n)/120;     
            y1_3 = multilinear5AD(func,imag(q1),real(q2),imag(q3),real(q4),real(q5),x0,p1,n)/120;            
            y1_4 = multilinear5AD(func,real(q1),imag(q2),imag(q3),real(q4),real(q5),x0,p1,n)/120;     
            y1_5 = multilinear5AD(func,real(q1),real(q2),imag(q3),imag(q4),real(q5),x0,p1,n)/120;            
            y1_6 = multilinear5AD(func,imag(q1),imag(q2),imag(q3),imag(q4),real(q5),x0,p1,n)/120;     
            y1_7 = multilinear5AD(func,imag(q1),real(q2),real(q3),imag(q4),real(q5),x0,p1,n)/120;            
            y1_8 = multilinear5AD(func,real(q1),imag(q2),real(q3),imag(q4),real(q5),x0,p1,n)/120;            
            y1_9 = multilinear5AD(func,real(q1),real(q2),real(q3),imag(q4),imag(q5),x0,p1,n)/120;            
            y1_10 = multilinear5AD(func,imag(q1),imag(q2),real(q3),imag(q4),imag(q5),x0,p1,n)/120;     
            y1_11 = multilinear5AD(func,imag(q1),real(q2),imag(q3),imag(q4),imag(q5),x0,p1,n)/120;            
            y1_12 = multilinear5AD(func,real(q1),imag(q2),imag(q3),imag(q4),imag(q5),x0,p1,n)/120;     
            y1_13 = multilinear5AD(func,real(q1),real(q2),imag(q3),real(q4),imag(q5),x0,p1,n)/120;            
            y1_14 = multilinear5AD(func,imag(q1),imag(q2),imag(q3),real(q4),imag(q5),x0,p1,n)/120;     
            y1_15 = multilinear5AD(func,imag(q1),real(q2),real(q3),real(q4),imag(q5),x0,p1,n)/120;            
            y1_16 = multilinear5AD(func,real(q1),imag(q2),real(q3),real(q4),imag(q5),x0,p1,n)/120;          
            y1_17 = multilinear5AD(func,real(q1),real(q2),real(q3),real(q4),imag(q5),x0,p1,n)/120;            
            y1_18 = multilinear5AD(func,imag(q1),imag(q2),real(q3),real(q4),imag(q5),x0,p1,n)/120;     
            y1_19 = multilinear5AD(func,imag(q1),real(q2),imag(q3),real(q4),imag(q5),x0,p1,n)/120;            
            y1_20 = multilinear5AD(func,real(q1),imag(q2),imag(q3),real(q4),imag(q5),x0,p1,n)/120;     
            y1_21 = multilinear5AD(func,real(q1),real(q2),imag(q3),imag(q4),imag(q5),x0,p1,n)/120;            
            y1_22 = multilinear5AD(func,imag(q1),imag(q2),imag(q3),imag(q4),imag(q5),x0,p1,n)/120;     
            y1_23 = multilinear5AD(func,imag(q1),real(q2),real(q3),imag(q4),imag(q5),x0,p1,n)/120;            
            y1_24 = multilinear5AD(func,real(q1),imag(q2),real(q3),imag(q4),imag(q5),x0,p1,n)/120;            
            y1_25 = multilinear5AD(func,real(q1),real(q2),real(q3),imag(q4),real(q5),x0,p1,n)/120;            
            y1_26 = multilinear5AD(func,imag(q1),imag(q2),real(q3),imag(q4),real(q5),x0,p1,n)/120;     
            y1_27 = multilinear5AD(func,imag(q1),real(q2),imag(q3),imag(q4),real(q5),x0,p1,n)/120;            
            y1_28 = multilinear5AD(func,real(q1),imag(q2),imag(q3),imag(q4),real(q5),x0,p1,n)/120;     
            y1_29 = multilinear5AD(func,real(q1),real(q2),imag(q3),real(q4),real(q5),x0,p1,n)/120;            
            y1_30 = multilinear5AD(func,imag(q1),imag(q2),imag(q3),real(q4),real(q5),x0,p1,n)/120;     
            y1_31 = multilinear5AD(func,imag(q1),real(q2),real(q3),real(q4),real(q5),x0,p1,n)/120;            
            y1_32 = multilinear5AD(func,real(q1),imag(q2),real(q3),real(q4),real(q5),x0,p1,n)/120;
            y1_1 = transf(y1_1,taylorder);
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);             
            y1_4 = transf(y1_4,taylorder);
            y1_5 = transf(y1_5,taylorder);
            y1_6 = transf(y1_6,taylorder);
            y1_7 = transf(y1_7,taylorder);             
            y1_8 = transf(y1_8,taylorder);
            y1_9 = transf(y1_9,taylorder);
            y1_10 = transf(y1_10,taylorder);
            y1_11 = transf(y1_11,taylorder);             
            y1_12 = transf(y1_12,taylorder);
            y1_13 = transf(y1_13,taylorder);
            y1_14 = transf(y1_14,taylorder);
            y1_15 = transf(y1_15,taylorder);             
            y1_16 = transf(y1_16,taylorder);            
            y1_17 = transf(y1_17,taylorder);
            y1_18 = transf(y1_18,taylorder);
            y1_19 = transf(y1_19,taylorder);             
            y1_20 = transf(y1_20,taylorder);
            y1_21 = transf(y1_21,taylorder);
            y1_22 = transf(y1_22,taylorder);
            y1_23 = transf(y1_23,taylorder);             
            y1_24 = transf(y1_24,taylorder);
            y1_25 = transf(y1_25,taylorder);
            y1_26 = transf(y1_26,taylorder);
            y1_27 = transf(y1_27,taylorder);             
            y1_28 = transf(y1_28,taylorder);
            y1_29 = transf(y1_29,taylorder);
            y1_30 = transf(y1_30,taylorder);
            y1_31 = transf(y1_31,taylorder);             
            y1_32 = transf(y1_32,taylorder);
            y1 = y1_1-y1_2-y1_3-y1_4-y1_5+y1_6-y1_7-y1_8-y1_9+y1_10+y1_11+y1_12-y1_13+y1_14-y1_15-y1_16+i*(y1_17-y1_18-y1_19-y1_20-y1_21+y1_22-y1_23-y1_24+y1_25-y1_26-y1_27-y1_28+y1_29-y1_30+y1_31+y1_32);                 
    end
end
if size(x0,1) >1
ytayl5=120*tcs(y1);
  else
      ytayl5=tcs(y1);
      ytayl5=120*ytayl5(6,:);
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

