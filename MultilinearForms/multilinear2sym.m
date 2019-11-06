function vec2sym =multilinear2sym(q1,q2,nphase,n)

%----------------------------------------------------
% This file computes  H^(n)*q1*q2 symbolicslly, where H^(n) is the hessian 
% of the map f^(n). 
%----------------------------------------------------

global  cds T1global T2global
       
    if n==1
        
        T2=T2global(:,:,:,1);
        vec2sym=tensor2op(T2,q1,q2,nphase);
    else
        if (q1==q2)
            
           V1=multilinear1sym(q1,n-1);
           V2=multilinear2sym(q1,q1,nphase,n-1);
           T2=T2global(:,:,:,n);
           V3=tensor2op(T2,V1,V1,nphase);
           T1=T1global(:,:,n);
           V4=T1*V2;
           vec2sym=V3+V4;
        else
           V1=multilinear1sym(q1,n-1);
           V2=multilinear1sym(q2,n-1);
           V3=multilinear2sym(q1,q2,nphase,n-1);
           T2=T2global(:,:,:,n);
           V4=tensor2op(T2,V1,V2,nphase);
           T1=T1global(:,:,n);
           V5=T1*V3;
           vec2sym=V4+V5;
        end
    end
