function T2op =tensor2op(H,q1,q2,nphase)
%----------------------------------------------------
%This file computes  H*q1*q2, where H is jacobian 
%of map f on the iterate  at xn. 
%----------------------------------------------------
global  cds
for i=1:nphase
  S(:,i)=H(:,:,i)*q1;
end
T2op=S*q2;

