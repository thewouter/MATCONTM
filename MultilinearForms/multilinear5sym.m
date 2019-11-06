function vec5 =multilinear5sym(q1,q2,q3,q4,q5,nphase,n)

%----------------------------------------------------
% This file computes  T^(n)*q1*q2*q3*q4*q5, where T^(n) is 5th derivative 
% of map f^(n) . 
%----------------------------------------------------
global  cds T1global T2global T3global T4global T5global 
if n==1
   T5=T5global(:,:,:,:,:,:,1);
    vec5=tensor5op(T5,q1,q2,q3,q4,q5,nphase);
else
 if (q1==q2 & q1 ==q3)
    if (q1==q4 & q1==q5)         
         Vj1=multilinear1sym(q1,n-1); 
         Vh1=multilinear2sym(q1,q1,nphase,n-1);
         VT=multilinear3sym(q1,q1,q1,nphase,n-1);
         VT4=multilinear4sym(q1,q1,q1,q1,nphase,n-1);
         T5=T5global(:,:,:,:,:,:,n);
         V1=tensor5op(T5,Vj1,Vj1,Vj1,Vj1,Vj1,nphase);
         T4=T4global(:,:,:,:,:,n);
         V2=tensor4op(T4,Vh1,Vj1,Vj1,Vj1,nphase);
         T3=T3global(:,:,:,:,n);
         V3=tensor3op(T3,Vh1,Vh1,Vj1,nphase);
         V4=tensor3op(T3,VT,Vj1,Vj1,nphase);
         T2=T2global(:,:,:,n);
         V5=tensor2op(T2,VT4,Vj1,nphase);
         V6=tensor2op(T2,VT,Vh1,nphase);
         T1=T1global(:,:,n);
         VT7=multilinear5sym(q1,q1,q1,q1,q1,nphase,n-1);
         V7=T1*VT7;
         vec5=V1+10.0*V2+15.0*V3+10.0*V4+5.0*V5+10.0*V6+V7;
     else % q1==q2==q3 noteq q4 and q5
         Vj1=multilinear1sym(q1,n);
         Vj4=multilinear1sym(q4,n-1);
         Vj5=multilinear1sym(q5,n-1);
         Vh11=multilinear2sym(q1,q1,nphase,n-1);
         Vh14=multilinear2sym(q1,q4,nphase,n-1);
         Vh15=multilinear2sym(q1,q5,nphase,n-1);
         Vh45=multilinear2sym(q4,q5,nphase,n-1);
         VT114=multilinear3sym(q1,q1,q4,nphase,n-1);
         VT115=multilinear3sym(q1,q1,q5,nphase,n-1);
         VT111=multilinear3sym(q1,q1,q1,nphase,n-1);
         VT145=multilinear3sym(q1,q4,q5,nphase,n-1);
         VT1114=multilinear4sym(q1,q1,q1,q4,nphase,n-1);
         VT1145=multilinear4sym(q1,q1,q4,q5,nphase,n-1);
         VT1115=multilinear4sym(q1,q1,q1,q5,nphase,n-1);
         T5=T5global(:,:,:,:,:,:,n);
         V1=tensor5op(T5,Vj1,Vj1,Vj1,Vj4,Vj5,nphase);
         T4=T4global(:,:,:,:,:,n);
         V2=tensor4op(T4,Vh11,Vj1,Vj4,Vj5,nphase);
         V3=tensor4op(T4,Vh14,Vj1,Vj1,Vj5,nphase);
         V4=tensor4op(T4,Vh15,Vj1,Vj1,Vj4,nphase);
         V5=tensor4op(T4,Vh45,Vj1,Vj1,Vj1,nphase);         
         T3=T3global(:,:,:,:,n);
         V6=tensor3op(T3,Vh11,Vh14,Vj5,nphase);
         V7=tensor3op(T3,Vh11,Vh15,Vj4,nphase);
                         
         V8=tensor3op(T3,Vh14,Vh15,Vj1,nphase);
         V9=tensor3op(T3,Vh14,Vh15,Vj1,nphase);
         V10=tensor3op(T3,Vh11,Vh45,Vj1,nphase);         
         V11=tensor3op(T3,VT114,Vj1,Vj5,nphase);
         V12=tensor3op(T3,VT115,Vj1,Vj4,nphase);
         V13=tensor3op(T3,VT145,Vj1,Vj1,nphase);  
         VE1=tensor3op(T3,VT111,Vj4,Vj5,nphase); 
         T2=T2global(:,:,:,n);
         V14=tensor2op(T2,VT1114,Vj5,nphase);
         V15=tensor2op(T2,VT114,Vh15,nphase);
         V16=tensor2op(T2,VT115,Vh14,nphase);
         V17=tensor2op(T2,VT111,Vh45,nphase);
         V18=tensor2op(T2,VT145,Vh11,nphase);
         V19=tensor2op(T2,VT1115,Vj4,nphase);         
         V20=tensor2op(T2,VT1145,Vj1,nphase);     
           
         T1=T1global(:,:,n);
         VT21=multilinear5sym(q1,q1,q1,q4,q5,nphase,n-1);
         V21=T1*VT21;
         vec51=V1+V5+V14+V17+V19+V21;
         vec52=3.0*(V2+V3+V4+V6+V7+V8+V9+V10+V11+V12+V13+V15+V16+V18+V20);
         vec5=vec51+vec52+VE1;
                 
    end
 else
      Vj1=multilinear1sym(q1,n-1);
      Vj2=multilinear1sym(q2,n-1);
      Vj3=multilinear1sym(q3,n-1);
      Vj4=multilinear1sym(q4,n-1);
      Vj5=multilinear1sym(q5,n-1);
      Vh12=multilinear2sym(q1,q2,nphase,n-1);
      Vh13=multilinear2sym(q1,q3,nphase,n-1);
      Vh14=multilinear2sym(q1,q4,nphase,n-1);
      Vh15=multilinear2sym(q1,q5,nphase,n-1);
      Vh23=multilinear2sym(q2,q3,nphase,n-1);
      Vh24=multilinear2sym(q2,q4,nphase,n-1);
      Vh25=multilinear2sym(q2,q5,nphase,n-1);
      Vh34=multilinear2sym(q3,q4,nphase,n-1);
      Vh35=multilinear2sym(q3,q5,nphase,n-1);
      Vh45=multilinear2sym(q4,q5,nphase,n-1);
      
      VT123=multilinear3sym(q1,q1,q3,nphase,n-1);
      VT135=multilinear3sym(q1,q3,q5,nphase,n-1);
      VT134=multilinear3sym(q1,q3,q4,nphase,n-1);
      VT124=multilinear3sym(q1,q2,q4,nphase,n-1);
      VT145=multilinear3sym(q1,q4,q5,nphase,n-1);
      VT125=multilinear3sym(q1,q2,q5,nphase,n-1);
      VT234=multilinear3sym(q2,q3,q4,nphase,n-1);
      VT235=multilinear3sym(q2,q3,q5,nphase,n-1);
      VT345=multilinear3sym(q3,q4,q5,nphase,n-1);
      VT245=multilinear3sym(q2,q4,q5,nphase,n-1);
      
      VT1234=multilinear4sym(q1,q2,q3,q4,nphase,n-1);
      VT1235=multilinear4sym(q1,q2,q3,q5,nphase,n-1);
      VT1345=multilinear4sym(q1,q3,q4,q5,nphase,n-1);
      VT1245=multilinear4sym(q1,q2,q4,q5,nphase,n-1);
      VT2345=multilinear4sym(q2,q3,q4,q5,nphase,n-1);
      
      T5=T5global(:,:,:,:,:,:,n);
      V1=tensor5op(T5,Vj1,Vj2,Vj3,Vj4,Vj5,nphase);
      T4=T4global(:,:,:,:,:,n);
      V2=tensor4op(T4,Vh12,Vj3,Vj4,Vj5,nphase);
      V3=tensor4op(T4,Vh13,Vj2,Vj4,Vj5,nphase);
      V4=tensor4op(T4,Vh14,Vj2,Vj3,Vj5,nphase);
      V5=tensor4op(T4,Vh15,Vj2,Vj3,Vj4,nphase);
      V6=tensor4op(T4,Vh23,Vj1,Vj4,Vj5,nphase);
      V7=tensor4op(T4,Vh24,Vj1,Vj3,Vj5,nphase);
      V8=tensor4op(T4,Vh25,Vj1,Vj3,Vj4,nphase);
      V9=tensor4op(T4,Vh35,Vj1,Vj2,Vj4,nphase);
      V10=tensor4op(T4,Vh45,Vj1,Vj2,Vj3,nphase);
      V11=tensor4op(T4,Vh34,Vj1,Vj2,Vj5,nphase);
      
      T3=T3global(:,:,:,:,n);
      V12=tensor3op(T3,Vh23,Vh14,Vj5,nphase);
      V13=tensor3op(T3,Vh23,Vh15,Vj4,nphase);
      V14=tensor3op(T3,Vh13,Vh24,Vj5,nphase);
      V15=tensor3op(T3,Vh24,Vh15,Vj4,nphase);
      V16=tensor3op(T3,Vh13,Vh25,Vj4,nphase);
      V17=tensor3op(T3,Vh14,Vh25,Vj3,nphase);
      V18=tensor3op(T3,Vh12,Vh34,Vj5,nphase);
      V19=tensor3op(T3,Vh34,Vh15,Vj2,nphase);
      V20=tensor3op(T3,Vh34,Vh25,Vj1,nphase);
      V21=tensor3op(T3,Vh12,Vh35,Vj4,nphase);
      V22=tensor3op(T3,Vh14,Vh35,Vj2,nphase);
      V23=tensor3op(T3,Vh24,Vh35,Vj1,nphase);
      V24=tensor3op(T3,Vh12,Vh45,Vj2,nphase);
      V25=tensor3op(T3,Vh13,Vh45,Vj2,nphase);
      V26=tensor3op(T3,Vh23,Vh45,Vj1,nphase);%
      V27=tensor3op(T3,VT124,Vj3,Vj5,nphase);
      V28=tensor3op(T3,VT125,Vj3,Vj4,nphase);
      V29=tensor3op(T3,VT134,Vj2,Vj5,nphase); 
      V30=tensor3op(T3,VT234,Vj1,Vj5,nphase);
      V31=tensor3op(T3,VT135,Vj2,Vj4,nphase);
      V32=tensor3op(T3,VT235,Vj1,Vj4,nphase);
      V33=tensor3op(T3,VT145,Vj2,Vj3,nphase);
      V34=tensor3op(T3,VT245,Vj1,Vj3,nphase);
      V35=tensor3op(T3,VT345,Vj1,Vj2,nphase);        
      
      T2=T2global(:,:,:,n);
      V36=tensor2op(T2,VT1234,Vj5,nphase);
      V37=tensor2op(T2,VT234,Vh15,nphase);
      V38=tensor2op(T2,VT125,Vh34,nphase);
      V39=tensor2op(T2,VT134,Vh25,nphase);
      
      V40=tensor2op(T2,VT124,Vh35,nphase);
      V41=tensor2op(T2,VT123,Vh45,nphase);
      V42=tensor2op(T2,VT145,Vh23,nphase);
      V43=tensor2op(T2,VT245,Vh13,nphase);
      V44=tensor2op(T2,VT135,Vh24,nphase);
      V45=tensor2op(T2,VT235,Vh14,nphase);
      V46=tensor2op(T2,VT345,Vh12,nphase);
      V47=tensor2op(T2,VT1235,Vj4,nphase);
      V48=tensor2op(T2,VT1245,Vj3,nphase);
      V49=tensor2op(T2,VT1345,Vj2,nphase);
      V50=tensor2op(T2,VT2345,Vj1,nphase);
      VE1=tensor3op(T3,VT123,Vj4,Vj5,nphase);
      
      T1=T1global(:,:,n);
      VT51=multilinear5sym(q1,q2,q3,q4,q5,nphase,n-1);
      V51=T1*VT51;
      vec51=V1+V2+V3+V4+V5+V6+V7+V8+V9+V10+V11+V12+V13+V14+V15+V16+V17+V18;
      vec52=V19+V20+V21+V22+V23+V24+V25+V26+V27+V28+V29+V30+V31+V32+V33+V34+V35+V36;
      vec53=V37+V38+V39+V40+V41+V42+V43+V44+V45+V46+V47+V48+V49+V50+V51;
      vec5=vec51+vec52+vec53+VE1;
      
      
  end
end

