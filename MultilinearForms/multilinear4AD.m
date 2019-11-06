function ytayl4 = multilinear4AD(func,q1,q2,q3,q4,x0,p1,n) 
%
%----------------------------------------------------
% This file computes  D^(n)*q1*q2*q3*q4 using automatic differentiation, where 
%D^(n) is the 4th order derivatives  of map f^(n). 
%----------------------------------------------------



taylorder=4; 
y1 = adtayl(0,4);
if (q1==q2)
    if (q1==q3)
        if (q1==q4)
            if isreal(q4)                
                hc=q1;             
                y1 = Bvv(func,x0,q1,p1,taylorder,n);             
            else
                y1_1 = Bvv(func,x0,real(q1),p1,taylorder,n);
                y1_2 = Bvv(func,x0,imag(q1),p1,taylorder,n);
                y1_3 = multilinear4AD(func,real(q1),real(q1),imag(q1),imag(q1),x0,p1,n)/24;
                y1_4 = multilinear4AD(func,real(q1),real(q1),real(q1),imag(q1),x0,p1,n)/24;
                y1_5 = multilinear4AD(func,real(q1),imag(q1),imag(q1),imag(q1),x0,p1,n)/24;
                y1_3 = transf(y1_3,taylorder); 
                y1_4 = transf(y1_4,taylorder);
                y1_5 = transf(y1_5,taylorder);
                y1 = y1_1+y1_2-6*y1_3+i*(4*y1_4-4*y1_5);                 
            end             
        else
            if isreal(q1) && isreal(q4)
                y14 = Bvv(func,x0,3.0*q1+q4,p1,taylorder,n);                                        
                y24 = Bvv(func,x0,3.0*q1-q4,p1,taylorder,n);                                    
                y34 = Bvv(func,x0,q1-q4,p1,taylorder,n);                       
                y44 = Bvv(func,x0,q1+q4,p1,taylorder,n);                         
                y54 = Bvv(func,x0,-q1-q4,p1,taylorder,n);                         
                y64 = Bvv(func,x0,-q1+q4,p1,taylorder,n);                         
                y1=1/192.0*(y14-y24+2*y34-2*y44-y54+y64);
            elseif isreal(q1)
                y1_1 = multilinear4AD(func,q1,q1,q1,real(q4),x0,p1,n)/24;
                y1_2 = multilinear4AD(func,q1,q1,q1,imag(q4),x0,p1,n)/24;
                y1_1 = transf(y1_1,taylorder);  
                y1_2 = transf(y1_2,taylorder);
                y1 = y1_1+i*y1_2; 
            elseif isreal(q4)
                y1_1 = multilinear4AD(func,real(q1),real(q1),real(q1),q4,x0,p1,n)/24;
                y1_2 = multilinear4AD(func,real(q1),imag(q1),imag(q1),q4,x0,p1,n)/24;
                y1_3 = multilinear4AD(func,real(q1),real(q1),imag(q1),q4,x0,p1,n)/24;
                y1_4 = multilinear4AD(func,imag(q1),imag(q1),imag(q1),q4,x0,p1,n)/24;
                y1_1 = transf(y1_1,taylorder);  
                y1_2 = transf(y1_2,taylorder);
                y1_3 = transf(y1_3,taylorder); 
                y1_4 = transf(y1_4,taylorder);
                y1 = y1_1-3*y1_2+i*(3*y1_3-y1_4); 
            else
                y1_1 = multilinear4AD(func,real(q1),real(q1),real(q1),real(q4),x0,p1,n)/24;
                y1_2 = multilinear4AD(func,real(q1),imag(q1),imag(q1),real(q4),x0,p1,n)/24;
                y1_3 = multilinear4AD(func,real(q1),real(q1),imag(q1),imag(q4),x0,p1,n)/24;
                y1_4 = multilinear4AD(func,imag(q1),imag(q1),imag(q1),imag(q4),x0,p1,n)/24;
                y1_5 = multilinear4AD(func,real(q1),real(q1),real(q1),imag(q4),x0,p1,n)/24;
                y1_6 = multilinear4AD(func,real(q1),imag(q1),imag(q1),imag(q4),x0,p1,n)/24;
                y1_7 = multilinear4AD(func,real(q1),real(q1),imag(q1),real(q4),x0,p1,n)/24;
                y1_8 = multilinear4AD(func,imag(q1),imag(q1),imag(q1),real(q4),x0,p1,n)/24;
                y1_1 = transf(y1_1,taylorder);  
                y1_2 = transf(y1_2,taylorder);
                y1_3 = transf(y1_3,taylorder); 
                y1_4 = transf(y1_4,taylorder);
                y1_5 = transf(y1_5,taylorder);  
                y1_6 = transf(y1_6,taylorder);
                y1_7 = transf(y1_7,taylorder); 
                y1_8 = transf(y1_8,taylorder);
                y1 = y1_1-3*y1_2-3*y1_3+y1_4+i*(y1_5-3*y1_6+3*y1_7-y1_8); 
            end
        end   
    else
        if isreal(q1) && isreal(q3) && isreal(q4)
           y61 = Bvv(func,x0,2*q1+q3+q4,p1,taylorder,n);         
           y62 = Bvv(func,x0,2*q1+q3-q4,p1,taylorder,n);         
           y63 = Bvv(func,x0,2*q1-q3-q4,p1,taylorder,n);         
           y64 = Bvv(func,x0,2*q1-q3+q4,p1,taylorder,n);         
           y65 = Bvv(func,x0,q3+q4,p1,taylorder,n);         
           y66 = Bvv(func,x0,q3-q4,p1,taylorder,n);         
           y76 = Bvv(func,x0,-q3-q4,p1,taylorder,n);        
           y86 = Bvv(func,x0,-q3+q4,p1,taylorder,n);        
           y1=1/192.0*(y61-y62+y63-y64-y65+y66-y76+y86);
        elseif isreal(q1) && isreal(q3)          
            y1_1 = multilinear4AD(func,q1,q1,q3,real(q4),x0,p1,n)/24;
            y1_2 = multilinear4AD(func,q1,q1,q3,imag(q4),x0,p1,n)/24;
            y1_1 = transf(y1_1,taylorder);  
            y1_2 = transf(y1_2,taylorder);
            y1 = y1_1+i*y1_2; 
        elseif isreal(q1) && isreal(q4)          
            y1_1 = multilinear4AD(func,q1,q1,real(q3),q4,x0,p1,n)/24;
            y1_2 = multilinear4AD(func,q1,q1,imag(q3),q4,x0,p1,n)/24;
            y1_1 = transf(y1_1,taylorder);  
            y1_2 = transf(y1_2,taylorder);
            y1 = y1_1+i*y1_2;            
        elseif isreal(q3) && isreal(q4)          
            y1_1 = multilinear4AD(func,real(q1),real(q1),q3,q4,x0,p1,n)/24;
            y1_2 = multilinear4AD(func,imag(q1),imag(q1),q3,q4,x0,p1,n)/24;
            y1_3 = multilinear4AD(func,real(q1),imag(q1),q3,q4,x0,p1,n)/24;
            y1_1 = transf(y1_1,taylorder);  
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);
            y1 = y1_1-y1_2+2*i*y1_3;
        elseif isreal(q1)
            y1_1 = multilinear4AD(func,q1,q1,real(q3),real(q4),x0,p1,n)/24;
            y1_2 = multilinear4AD(func,q1,q1,imag(q3),imag(q4),x0,p1,n)/24;
            y1_3 = multilinear4AD(func,q1,q1,real(q3),imag(q4),x0,p1,n)/24;
            y1_4 = multilinear4AD(func,q1,q1,imag(q3),real(q4),x0,p1,n)/24;
            y1_1 = transf(y1_1,taylorder);  
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);
            y1_4 = transf(y1_4,taylorder);
            y1 = y1_1-y1_2+i*(y1_3+y1_4);            
        elseif isreal(q3)
            y1_1 = multilinear4AD(func,real(q1),real(q1),q3,real(q4),x0,p1,n)/24;
            y1_2 = multilinear4AD(func,imag(q1),imag(q1),q3,real(q4),x0,p1,n)/24;
            y1_3 = multilinear4AD(func,real(q1),imag(q1),q3,imag(q4),x0,p1,n)/24;
            y1_4 = multilinear4AD(func,real(q1),real(q1),q3,imag(q4),x0,p1,n)/24;
            y1_5 = multilinear4AD(func,imag(q1),imag(q1),q3,imag(q4),x0,p1,n)/24;
            y1_6 = multilinear4AD(func,real(q1),imag(q1),q3,real(q4),x0,p1,n)/24;
            y1_1 = transf(y1_1,taylorder);  
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);
            y1_4 = transf(y1_4,taylorder);
            y1_5 = transf(y1_5,taylorder);
            y1_6 = transf(y1_6,taylorder);
            y1 = y1_1-y1_2-2*y1_3+i*(y1_4-y1_5+2*y1_6);           
        elseif isreal(q4)
            y1_1 = multilinear4AD(func,real(q1),real(q1),real(q3),q4,x0,p1,n)/24;
            y1_2 = multilinear4AD(func,imag(q1),imag(q1),real(q3),q4,x0,p1,n)/24;
            y1_3 = multilinear4AD(func,real(q1),imag(q1),imag(q3),q4,x0,p1,n)/24;
            y1_4 = multilinear4AD(func,real(q1),real(q1),imag(q3),q4,x0,p1,n)/24;
            y1_5 = multilinear4AD(func,imag(q1),imag(q1),imag(q3),q4,x0,p1,n)/24;
            y1_6 = multilinear4AD(func,real(q1),imag(q1),real(q3),q4,x0,p1,n)/24;
            y1_1 = transf(y1_1,taylorder);  
            y1_2 = transf(y1_2,taylorder);
            y1_3 = transf(y1_3,taylorder);
            y1_4 = transf(y1_4,taylorder);
            y1_5 = transf(y1_5,taylorder);
            y1_6 = transf(y1_6,taylorder);
            y1 = y1_1-y1_2-2*y1_3+i*(y1_4-y1_5+2*y1_6);      
        else
            y1_1 = multilinear4AD(func,real(q1),real(q1),real(q3),real(q4),x0,p1,n)/24;
            y1_2 = multilinear4AD(func,real(q1),real(q1),imag(q3),imag(q4),x0,p1,n)/24;
            y1_3 = multilinear4AD(func,imag(q1),imag(q1),real(q3),real(q4),x0,p1,n)/24;
            y1_4 = multilinear4AD(func,imag(q1),imag(q1),imag(q3),imag(q4),x0,p1,n)/24;
            y1_5 = multilinear4AD(func,real(q1),imag(q1),real(q3),imag(q4),x0,p1,n)/24;
            y1_6 = multilinear4AD(func,real(q1),imag(q1),imag(q3),real(q4),x0,p1,n)/24;            
            y1_7 = multilinear4AD(func,real(q1),real(q1),real(q3),imag(q4),x0,p1,n)/24;
            y1_8 = multilinear4AD(func,real(q1),real(q1),imag(q3),real(q4),x0,p1,n)/24;
            y1_9 = multilinear4AD(func,imag(q1),imag(q1),real(q3),imag(q4),x0,p1,n)/24;
            y1_10 = multilinear4AD(func,imag(q1),imag(q1),imag(q3),real(q4),x0,p1,n)/24;
            y1_11 = multilinear4AD(func,real(q1),imag(q1),real(q3),real(q4),x0,p1,n)/24;
            y1_12 = multilinear4AD(func,real(q1),imag(q1),imag(q3),imag(q4),x0,p1,n)/24;
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
            y1 = y1_1-y1_2-y1_3+y1_4-2*y1_5-2*y1_6+i*(y1_7+y1_8-y1_9-y1_10+2*y1_11-2*y1_12);                 
        end
    end    
else
    if isreal(q1) && isreal(q2) && isreal(q3) && isreal(q4)
        y81 = Bvv(func,x0,q1+q2+q3+q4,p1,taylorder,n);    
        y82 = Bvv(func,x0,q1+q2+q3-q4,p1,taylorder,n);    
        y83 = Bvv(func,x0,q1+q2-q3+q4,p1,taylorder,n);    
        y84 = Bvv(func,x0,q1+q2-q3-q4,p1,taylorder,n);       
        y85 = Bvv(func,x0,q1-q2+q3+q4,p1,taylorder,n);    
        y86 = Bvv(func,x0,q1-q2+q3-q4,p1,taylorder,n);   
        y87 = Bvv(func,x0,q1-q2-q3+q4,p1,taylorder,n);   
        y88 = Bvv(func,x0,q1-q2-q3-q4,p1,taylorder,n);    
        y1=1/192.0*(y81-y82-y83+y84-y85+y86+y87-y88); 
    elseif isreal(q1) && isreal(q2) && isreal(q3)        
        y1_1 = multilinear4AD(func,q1,q2,q3,real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,q1,q2,q3,imag(q4),x0,p1,n)/24;        
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1 = y1_1+i*y1_2;     
    elseif isreal(q1) && isreal(q2) && isreal(q4)        
        y1_1 = multilinear4AD(func,q1,q2,real(q3),q4,x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,q1,q2,imag(q3),q4,x0,p1,n)/24;        
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1 = y1_1+i*y1_2;    
    elseif isreal(q1) && isreal(q3) && isreal(q4)        
        y1_1 = multilinear4AD(func,q1,real(q2),q3,q4,x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,q1,imag(q2),q3,q4,x0,p1,n)/24;        
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1 = y1_1+i*y1_2;    
    elseif isreal(q2) && isreal(q3) && isreal(q4)        
        y1_1 = multilinear4AD(func,real(q1),q2,q3,q4,x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),q2,q3,q4,x0,p1,n)/24;        
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1 = y1_1+i*y1_2;
    elseif isreal(q1) && isreal(q2)
        y1_1 = multilinear4AD(func,q1,q2,real(q3),real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,q1,q2,imag(q3),imag(q4),x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,q1,q2,real(q3),imag(q4),x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,q1,q2,imag(q3),real(q4),x0,p1,n)/24;      
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1 = y1_1-y1_2+i*(y1_3+y1_4); 
    elseif isreal(q1) && isreal(q3)
        y1_1 = multilinear4AD(func,q1,real(q2),q3,real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,q1,imag(q2),q3,imag(q4),x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,q1,real(q2),q3,imag(q4),x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,q1,imag(q2),q3,real(q4),x0,p1,n)/24;      
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1 = y1_1-y1_2+i*(y1_3+y1_4);
    elseif isreal(q1) && isreal(q4)
        y1_1 = multilinear4AD(func,q1,real(q2),real(q3),q4,x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,q1,imag(q2),imag(q3),q4,x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,q1,real(q2),imag(q3),q4,x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,q1,imag(q2),real(q3),q4,x0,p1,n)/24;      
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1 = y1_1-y1_2+i*(y1_3+y1_4);        
    elseif isreal(q2) && isreal(q3)
        y1_1 = multilinear4AD(func,real(q1),q2,q3,real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),q2,q3,imag(q4),x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,real(q1),q2,q3,imag(q4),x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,imag(q1),q2,q3,real(q4),x0,p1,n)/24;      
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1 = y1_1-y1_2+i*(y1_3+y1_4);       
    elseif isreal(q2) && isreal(q4)
        y1_1 = multilinear4AD(func,real(q1),q2,real(q3),q4,x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),q2,imag(q3),q4,x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,real(q1),q2,imag(q3),q4,x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,imag(q1),q2,real(q3),q4,x0,p1,n)/24;      
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1 = y1_1-y1_2+i*(y1_3+y1_4);
    elseif isreal(q3) && isreal(q4)
        y1_1 = multilinear4AD(func,real(q1),real(q2),q3,q4,x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),imag(q2),q3,q4,x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,real(q1),imag(q2),q3,q4,x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,imag(q1),real(q2),q3,q4,x0,p1,n)/24;      
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1 = y1_1-y1_2+i*(y1_3+y1_4);
    elseif isreal(q1)
        y1_1 = multilinear4AD(func,q1,real(q2),real(q3),real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,q1,imag(q2),imag(q3),real(q4),x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,q1,imag(q2),real(q3),imag(q4),x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,q1,real(q2),imag(q3),imag(q4),x0,p1,n)/24;    
        y1_5 = multilinear4AD(func,q1,real(q2),real(q3),imag(q4),x0,p1,n)/24;        
        y1_6 = multilinear4AD(func,q1,imag(q2),imag(q3),imag(q4),x0,p1,n)/24;        
        y1_7 = multilinear4AD(func,q1,imag(q2),real(q3),real(q4),x0,p1,n)/24;        
        y1_8 = multilinear4AD(func,q1,real(q2),imag(q3),real(q4),x0,p1,n)/24;     
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1_5 = transf(y1_5,taylorder);          
        y1_6 = transf(y1_6,taylorder);                
        y1_7 = transf(y1_7,taylorder);
        y1_8 = transf(y1_8,taylorder);
        y1 = y1_1-y1_2-y1_3-y1_4+i*(y1_5-y1_6+y1_7+y1_8);   
    elseif isreal(q2)
        y1_1 = multilinear4AD(func,real(q1),q2,real(q3),real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),q2,imag(q3),real(q4),x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,imag(q1),q2,real(q3),imag(q4),x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,real(q1),q2,imag(q3),imag(q4),x0,p1,n)/24;    
        y1_5 = multilinear4AD(func,real(q1),q2,real(q3),imag(q4),x0,p1,n)/24;        
        y1_6 = multilinear4AD(func,imag(q1),q2,imag(q3),imag(q4),x0,p1,n)/24;        
        y1_7 = multilinear4AD(func,imag(q1),q2,real(q3),real(q4),x0,p1,n)/24;        
        y1_8 = multilinear4AD(func,real(q1),q2,imag(q3),real(q4),x0,p1,n)/24;     
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1_5 = transf(y1_5,taylorder);          
        y1_6 = transf(y1_6,taylorder);                
        y1_7 = transf(y1_7,taylorder);
        y1_8 = transf(y1_8,taylorder);
        y1 = y1_1-y1_2-y1_3-y1_4+i*(y1_5-y1_6+y1_7+y1_8);      
    elseif isreal(q3)
        y1_1 = multilinear4AD(func,real(q1),real(q2),q3,real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),imag(q2),q3,real(q4),x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,imag(q1),real(q2),q3,imag(q4),x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,real(q1),imag(q2),q3,imag(q4),x0,p1,n)/24;    
        y1_5 = multilinear4AD(func,real(q1),real(q2),q3,imag(q4),x0,p1,n)/24;        
        y1_6 = multilinear4AD(func,imag(q1),imag(q2),q3,imag(q4),x0,p1,n)/24;        
        y1_7 = multilinear4AD(func,imag(q1),real(q2),q3,real(q4),x0,p1,n)/24;        
        y1_8 = multilinear4AD(func,real(q1),imag(q2),q3,real(q4),x0,p1,n)/24;     
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1_5 = transf(y1_5,taylorder);          
        y1_6 = transf(y1_6,taylorder);                
        y1_7 = transf(y1_7,taylorder);
        y1_8 = transf(y1_8,taylorder);
        y1 = y1_1-y1_2-y1_3-y1_4+i*(y1_5-y1_6+y1_7+y1_8);     
    elseif isreal(q4)
        y1_1 = multilinear4AD(func,real(q1),real(q2),real(q3),q4,x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),imag(q2),real(q3),q4,x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,imag(q1),real(q2),imag(q3),q4,x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,real(q1),imag(q2),imag(q3),q4,x0,p1,n)/24;    
        y1_5 = multilinear4AD(func,real(q1),real(q2),imag(q3),q4,x0,p1,n)/24;        
        y1_6 = multilinear4AD(func,imag(q1),imag(q2),imag(q3),q4,x0,p1,n)/24;        
        y1_7 = multilinear4AD(func,imag(q1),real(q2),real(q3),q4,x0,p1,n)/24;        
        y1_8 = multilinear4AD(func,real(q1),imag(q2),real(q3),q4,x0,p1,n)/24;     
        y1_1 = transf(y1_1,taylorder);          
        y1_2 = transf(y1_2,taylorder);                
        y1_3 = transf(y1_3,taylorder);
        y1_4 = transf(y1_4,taylorder);
        y1_5 = transf(y1_5,taylorder);          
        y1_6 = transf(y1_6,taylorder);                
        y1_7 = transf(y1_7,taylorder);
        y1_8 = transf(y1_8,taylorder);
        y1 = y1_1-y1_2-y1_3-y1_4+i*(y1_5-y1_6+y1_7+y1_8);
    else        
        y1_1 = multilinear4AD(func,real(q1),real(q2),real(q3),real(q4),x0,p1,n)/24;        
        y1_2 = multilinear4AD(func,imag(q1),imag(q2),real(q3),real(q4),x0,p1,n)/24;        
        y1_3 = multilinear4AD(func,imag(q1),real(q2),imag(q3),real(q4),x0,p1,n)/24;        
        y1_4 = multilinear4AD(func,real(q1),imag(q2),imag(q3),real(q4),x0,p1,n)/24;    
        y1_5 = multilinear4AD(func,real(q1),real(q2),imag(q3),imag(q4),x0,p1,n)/24;        
        y1_6 = multilinear4AD(func,imag(q1),imag(q2),imag(q3),imag(q4),x0,p1,n)/24;        
        y1_7 = multilinear4AD(func,imag(q1),real(q2),real(q3),imag(q4),x0,p1,n)/24;        
        y1_8 = multilinear4AD(func,real(q1),imag(q2),real(q3),imag(q4),x0,p1,n)/24;            
        y1_9 = multilinear4AD(func,real(q1),real(q2),imag(q3),real(q4),x0,p1,n)/24;        
        y1_10 = multilinear4AD(func,imag(q1),imag(q2),imag(q3),real(q4),x0,p1,n)/24;        
        y1_11 = multilinear4AD(func,imag(q1),real(q2),imag(q3),imag(q4),x0,p1,n)/24;        
        y1_12 = multilinear4AD(func,real(q1),imag(q2),imag(q3),imag(q4),x0,p1,n)/24;    
        y1_13 = multilinear4AD(func,real(q1),real(q2),real(q3),imag(q4),x0,p1,n)/24;        
        y1_14 = multilinear4AD(func,imag(q1),imag(q2),real(q3),imag(q4),x0,p1,n)/24;        
        y1_15 = multilinear4AD(func,imag(q1),real(q2),real(q3),real(q4),x0,p1,n)/24;        
        y1_16 = multilinear4AD(func,real(q1),imag(q2),real(q3),real(q4),x0,p1,n)/24; 
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
        y1 = y1_1-y1_2-y1_3-y1_4-y1_5+y1_6-y1_7-y1_8+i*(y1_9-y1_10-y1_11-y1_12+y1_13-y1_14+y1_15+y1_16);     
    end
end      
if size(x0,1) >1
ytayl4=24*tcs(y1);
  else
      ytayl4=tcs(y1);
      ytayl4=24*ytayl4(5,:);
end

%------------------------------------------------------------
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

