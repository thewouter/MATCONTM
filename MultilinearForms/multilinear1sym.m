function vec1sym =multilinear1sym(q1,n)
%----------------------------------------------------
% This file computes  A^(n)*q1 symbolically, where A^(n) is the Jacobian 
% of the map f^(n). 
%----------------------------------------------------

global  cds T1global 
  
      if n==1
        T1=T1global(:,:,1);
        vec1sym=T1*q1;
    else
                
           V1=multilinear1sym(q1,n-1);
           T1=T1global(:,:,n);
           vec1sym=T1*V1;
        
    end
