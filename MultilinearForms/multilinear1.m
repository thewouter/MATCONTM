function vec1 = multilinear1(mapsf,q1,x0,p,n,increment)

                

%----------------------------------------------------------
%This file computes the multilinear function A^(n)(q1) where
%A^(n) is  the  Jacobian of the nth iterate. 
%----------------------------------------------------

global  cds
if ((cds.options.AutDerivative>0) && (n>=cds.options.AutDerivativeIte )) || ((cds.options.AutDerivative>0)&& (cds.options.SymDerivative <1))
    vec1=multilinear1AD(mapsf,q1,x0,p,n);
else
if (cds.options.SymDerivative >=1)
   vec1=multilinear1sym(q1,n);
   vec1=vec1(:,end);       
else
      vec1 = Av(mapsf,q1,x0,p,n,increment);
     
    end
end

%----------------------------------------------------
function tempvec = Av(mapsf,vq,x0,p,n,increment)
  f1 = x0 + increment*(vq);
  f2 = x0 - increment*(vq);
  for i=1:n
      f1 = feval(mapsf, 0, f1, p{:});
      f2 = feval(mapsf, 0, f2, p{:});
  end
  tempvec = (f1-f2)/(2.0*increment);