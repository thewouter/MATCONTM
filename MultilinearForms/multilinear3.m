function vec3 = multilinear3(mapsf,q1,q2,q3,x0,p,n,increment)
                 
              
%--------------------------------------------------------------
% This file computes the multilinear function C(q1,q2,q3)  where
% C = D^3(F(x0)), the 3rd derivative of the map wrt to phase
% variables only. 
%--------------------------------------------------------------

global cds
nphase=size(x0,1);
if ((cds.options.AutDerivative>0) && (n>=cds.options.AutDerivativeIte ) || (cds.options.AutDerivative>0)&& (cds.options.SymDerivative <3))
    vec3=multilinear3AD(mapsf,q1,q2,q3,x0,p,n); 
    vec3=vec3(:,end); 
elseif (cds.options.SymDerivative >=3)
     vec3=multilinear3sym(q1,q2,q3,nphase,n);
         
else
  if (q1==q2)
    if (q1==q3)
        vec3 = Cvvv(mapsf,q1,x0,p,n,increment);
    else
        part1 = Cvvv(mapsf,q1+q3,x0,p,n,increment);
        part2 = Cvvv(mapsf,q1-q3,x0,p,n,increment); 
        part3 = Cvvv(mapsf,q3,x0,p,n,increment);
        vec3 = (part1 - part2 - 2.0*part3)/6.0;
    end
  else
    part1 = Cvvv(mapsf,q1+q2+q3,x0,p,n,increment);
    part2 = Cvvv(mapsf,q1+q2-q3,x0,p,n,increment);
    part3 = Cvvv(mapsf,q1-q2+q3,x0,p,n,increment);
    part4 = Cvvv(mapsf,q1-q2-q3,x0,p,n,increment);
    vec3 = (part1 - part2 - part3 + part4)/24.0;
  end
end

%----------------------------------------------------
function tempvec = Cvvv(mapsf,vq,x0,p,n,increment)
  f1 = x0 + 3.0*increment*vq;
  f2 = x0 +     increment*vq;
  f3 = x0 -     increment*vq;
  f4 = x0 - 3.0*increment*vq;
  for i=1:n
    f1 = feval(mapsf, 0, f1, p{:});
    f2 = feval(mapsf, 0, f2, p{:});
    f3 = feval(mapsf, 0, f3, p{:});
    f4 = feval(mapsf, 0, f4, p{:});
  end
  tempvec = (f1 - 3.0*f2 + 3.0*f3 - f4)/(8.0*increment^3);
