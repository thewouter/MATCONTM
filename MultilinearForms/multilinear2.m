function vec2 = multilinear2(mapsf,q1,q2,x0,p,n,increment)
            

%----------------------------------------------------------
%This file computes the multilinear function B(q1,q2) where
%B = D^2(F(x0)), the second derivative of the map. 
%----------------------------------------------------

global  cds
nphase=size(x0,1);
if  ((cds.options.AutDerivative>0) && (n>=cds.options.AutDerivativeIte )) || ((cds.options.AutDerivative>0)&& (cds.options.SymDerivative <2))
   
    vec2=multilinear2AD(mapsf,q1,q2,x0,p,n);
    vec2=vec2(:,end); 
elseif (cds.options.SymDerivative >=2)
   vec2=multilinear2sym(q1,q2,nphase,n); 
   
        
else
    if (q1==q2)
         vec2 = Bvv(mapsf,q1,x0,p,n,increment);
     else
      part1 = Bvv(mapsf,q1+q2,x0,p,n,increment);
      part2 = Bvv(mapsf,q1-q2,x0,p,n,increment);
      vec2 = (part1-part2)/4.0;
     end
end

%----------------------------------------------------
function tempvec = Bvv(mapsf,vq,x0,p,n,increment)
  f0 = x0; 
  f1 = x0 + increment*(vq);
  f2 = x0 - increment*(vq);
  for i=1:n
      f0 = feval(mapsf, 0, f0, p{:});
      f1 = feval(mapsf, 0, f1, p{:});
      f2 = feval(mapsf, 0, f2, p{:});
  end
  tempvec = (f1+f2-2.0*f0)/(increment^2);