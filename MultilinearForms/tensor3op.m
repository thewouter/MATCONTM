function tenss3 =tensor3op(T,q1,q2,q3,nphase)
%----------------------------------------------------
%This file computes  T*q1*q2*q3, where T is 3rd derivative 
%of original map f at xn. 
%----------------------------------------------------
global  cds
for b=1:nphase
    S1=T(:,:,:,b);
    BB=tensor2op(S1,q1,q2,nphase);
    S(:,b)=BB;
end
tenss3=S*q3;  
    


