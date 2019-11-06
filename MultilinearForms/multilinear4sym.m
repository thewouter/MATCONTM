function vec4sym =multilinear4sym(q1,q2,q3,q4,nphase,n)

%----------------------------------------------------
% This file computes  D^(n)*q1*q2*q3*q4 symbolically, where D^(n) is 4th derivative 
% of map f^(n) . 
%----------------------------------------------------

global  cds T1global T2global T3global T4global
if (n==1)
    T4=T4global(:,:,:,:,:,1);
    vec4sym=tensor4op(T4,q1,q2,q3,q4,nphase);
    
else
  if (q1==q2)
    if (q1==q3)
        if (q1==q4)
            Vj=multilinear1sym(q1,n-1);
            Vh=multilinear2sym(q1,q1,nphase,n-1);
            VT=multilinear3sym(q1,q1,q1,nphase,n-1);
            T4=T4global(:,:,:,:,:,n);
            V1=tensor4op(T4,Vj,Vj,Vj,Vj,nphase);
            T3=T3global(:,:,:,:,n);
            V2=tensor3op(T3,Vh,Vj,Vj,nphase); 
            T2=T2global(:,:,:,n);
            V3=tensor2op(T2,Vh,Vh,nphase);              
            V4=tensor2op(T2,VT,Vj,nphase);
            VT5=multilinear4sym(q1,q1,q1,q1,nphase,n-1);
            T1=T1global(:,:,n);
            V5=T1*VT5;
            vec4sym=V1+6.0*V2+3.0*V3+4.0*V4+V5;
        else
            Vj1=multilinear1sym(q1,n-1);
            Vj4=multilinear1sym(q4,n-1);
            
            Vh11=multilinear2sym(q1,q1,nphase,n-1);
            Vh14=multilinear2sym(q1,q4,nphase,n-1);
            VT111=multilinear3sym(q1,q1,q1,nphase,n-1);
            VT114=multilinear3sym(q1,q1,q4,nphase,n-1);   
            
            T4=T4global(:,:,:,:,:,n);
            V1=tensor4op(T4,Vj1,Vj1,Vj1,Vj4,nphase);
            T3=T3global(:,:,:,:,n);
            V2=tensor3op(T3,Vh11,Vj1,Vj4,nphase);
            V3=tensor3op(T3,Vh14,Vj1,Vj1,nphase);
            
            T2=T2global(:,:,:,n);            
            V4=tensor2op(T2,Vh11,Vh14,nphase);  
            V5=tensor2op(T2,VT114,Vj1,nphase);
            V6=tensor2op(T2,VT111,Vj4,nphase);
            VT5=multilinear4sym(q1,q1,q1,q4,nphase,n-1);
            T1=T1global(:,:,n);
            V7=T1*VT5;
            vec4sym=V1+V6+V7+3.0*(V2+V3+V4+V5) ;
        end
      else
        Vj1=multilinear1sym(q1,n-1);
        Vj3=multilinear1sym(q3,n-1);
        Vj4=multilinear1sym(q4,n-1);
        Vh11=multilinear2sym(q1,q1,nphase,n-1);
        Vh13=multilinear2sym(q1,q3,nphase,n-1);
        Vh34=multilinear2sym(q3,q4,nphase,n-1);
        Vh14=multilinear2sym(q1,q4,nphase,n-1);
        VT113=multilinear3sym(q1,q1,q3,nphase,n-1);
        VT134=multilinear3sym(q1,q3,q4,nphase,n-1);
        VT114=multilinear3sym(q1,q1,q4,nphase,n-1);
        
        T4=T4global(:,:,:,:,:,n);
        V1=tensor4op(T4,Vj1,Vj1,Vj3,Vj4,nphase);
        T3=T3global(:,:,:,:,n);
        V2=tensor3op(T3,Vh11,Vj3,Vj4,nphase);
        V3=tensor3op(T3,Vh13,Vj1,Vj4,nphase);%2
        V4=tensor3op(T3,Vh14,Vj1,Vj3,nphase);%2
        V5=tensor3op(T3,Vh34,Vj1,Vj1,nphase);
        
        T2=T2global(:,:,:,n);
        V6=tensor2op(T2,Vh13,Vh14,nphase);%2
        V7=tensor2op(T2,VT114,Vj3,nphase);
        V8=tensor2op(T2,Vh11,Vh34,nphase);
        V9=tensor2op(T2,VT113,Vj4,nphase);
        V10=tensor2op(T2,VT134,Vj1,nphase);%2
        T1=T1global(:,:,n);
        VT11=multilinear4sym(q1,q1,q3,q4,nphase,n-1);
        V11=T1*VT11;
        vec4sym=V1+V2+V5+V7+V8+V9+V11+2.0*(V3+V4+V6+V10);        
     end    
    else
        Vj1=multilinear1sym(q1,n-1);
        Vj2=multilinear1sym(q2,n-1);
        Vj3=multilinear1sym(q3,n-1);
        Vj4=multilinear1sym(q4,n-1);
        Vh12= multilinear2sym(q1,q2,nphase,n-1);
        Vh13=multilinear2sym(q1,q3,nphase,n-1);
        Vh14=multilinear2sym(q1,q4,nphase,n-1);
        Vh23=multilinear2sym(q2,q3,nphase,n-1);
        Vh24=multilinear2sym(q2,q4,nphase,n-1);
        Vh34=multilinear2sym(q3,q4,nphase,n-1);
        
        VT134=multilinear3sym(q1,q3,q4,nphase,n-1);
        VT123=multilinear3sym(q1,q2,q3,nphase,n-1);        
        VT124=multilinear3sym(q1,q2,q4,nphase,n-1);
        VT234=multilinear3sym(q2,q3,q4,nphase,n-1);
        T4=T4global(:,:,:,:,:,n);
        V1=tensor4op(T4,Vj1,Vj2,Vj3,Vj4,nphase);
        T3=T3global(:,:,:,:,n);
        V2=tensor3op(T3,Vh12,Vj3,Vj4,nphase);
        V3=tensor3op(T3,Vh13,Vj2,Vj4,nphase);
        V4=tensor3op(T3,Vh14,Vj2,Vj3,nphase);
        V5=tensor3op(T3,Vh23,Vj1,Vj4,nphase);
        V6=tensor3op(T3,Vh24,Vj1,Vj3,nphase);
        V7=tensor3op(T3,Vh34,Vj1,Vj2,nphase);
        
        T2=T2global(:,:,:,n);
        V8=tensor2op(T2,Vh23,Vh14,nphase);
        V9=tensor2op(T2,Vh13,Vh24,nphase);
        V10=tensor2op(T2,VT124,Vj3,nphase);        
        V11=tensor2op(T2,Vh12,Vh34,nphase);
        V12=tensor2op(T2,VT123,Vj4,nphase);
        V13=tensor2op(T2,VT134,Vj2,nphase);
        V14=tensor2op(T2,VT234,Vj1,nphase);      
               
        VT15= multilinear4sym(q1,q2,q3,q4,nphase,n-1);
        T1=T1global(:,:,n);         
        V15=T1*VT15;
        vec4sym=V1+V2+V3+V4+V5+V6+V7+V8+V9+V10+V11+V12+V13+V14+V15;
        
   end
end



