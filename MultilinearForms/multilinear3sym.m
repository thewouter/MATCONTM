function vec3sym = multilinear3sym(q1,q2,q3,nphase,n)
              
%--------------------------------------------------------------
%This file computes the multilinear function C(q1,q2,q3) symbolically where
%C = D^3(F(x0)), the 3rd derivative of the map wrt to phase
%variables only. 
%--------------------------------------------------------------

global cds T1global T2global T3global

 if n==1
       T3=T3global(:,:,:,:,1);
       vec3sym=tensor3op(T3,q1,q2,q3,nphase);
   else
       if (q1==q2)
          if (q1==q3)
             Vj=multilinear1sym(q1,n-1);
             Vh=multilinear2sym(q1,q1,nphase,n-1);
             T3=T3global(:,:,:,:,n);
             V1=tensor3op(T3,Vj,Vj,Vj,nphase);
             T2=T2global(:,:,:,n);
             V2=tensor2op(T2,Vh,Vj,nphase);
             VT3=multilinear3sym(q1,q1,q1,nphase,n-1);
             T1=T1global(:,:,n);
             V3=T1*VT3;
             vec3sym=V1+3.0*V2+V3;
          else
             Vj1=multilinear1sym(q1,n-1);
             Vj3=multilinear1sym(q3,n-1);
             Vh1=multilinear2sym(q1,q1,nphase,n-1);
             Vh2=multilinear2sym(q1,q3,nphase,n-1);%=vh3 
             T3=T3global(:,:,:,:,n);
             V1=tensor3op(T3,Vj1,Vj1,Vj3,nphase);
             T2=T2global(:,:,:,n);
             V2=tensor2op(T2,Vh1,Vj3,nphase);
             V3=tensor2op(T2,Vh2,Vj1,nphase);
             VT4=multilinear3sym(q1,q1,q3,nphase,n-1);
             T1=T1global(:,:,n);
             V4=T1*VT4;
             vec3sym=V1+V2+2.0*V3+V4;
          end
       else       
         Vj1=multilinear1sym(q1,n-1);
         Vj2=multilinear1sym(q2,n-1);
         Vj3=multilinear1sym(q3,n-1);
         Vh1=multilinear2sym(q1,q2,nphase,n-1);
         Vh2=multilinear2sym(q1,q3,nphase,n-1);
         Vh3=multilinear2sym(q2,q3,nphase,n-1);
         T3=T3global(:,:,:,:,n);
         V1=tensor3op(T3,Vj1,Vj2,Vj3,nphase);
         T2=T2global(:,:,:,n);
         V2=tensor2op(T2,Vh1,Vj3,nphase);
         V3=tensor2op(T2,Vh2,Vj2,nphase);
         V4=tensor2op(T2,Vh3,Vj1,nphase);
         VT4=multilinear3sym(q1,q2,q3,nphase,n-1);
         T1=T1global(:,:,n);
         V5=T1*VT4;
         vec3sym=V1+V2+V3+V4+V5;       
       end
 end

