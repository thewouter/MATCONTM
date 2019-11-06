function vec4 = multilinear4(func,q1,q2,q3,q4,x0,p,n,increment)
%--------------------------------------------------------------
%This file computes the multilinear function D(q1,q2,q3,q4) where
%D = D^4(F(x0)), the fourth derivative of the map wrt to phase
%variables only. First we decide whether q1=q2, then the rest.
%--------------------------------------------------------------

global  cds
nphase=size(x0,1);
if  ((cds.options.AutDerivative>0) && (n>=cds.options.AutDerivativeIte )) || ((cds.options.AutDerivative>0)&& (cds.options.SymDerivative <4))
    vec4=multilinear4AD(func,q1,q2,q3,q4,x0,p,n);
    vec4=vec4(:,end); 
elseif (cds.options.SymDerivative >=4)
    vec4=multilinear4sym(q1,q2,q3,q4,nphase,n); 
else
  if (q1==q2)
    if (q1==q3)
      if (q1==q4)
        vec4 = Dvvvv(func,q1,x0,p,n,increment);
      else
        part1 = Dvvvv(func,3.0*q1+q4,x0,p,n,increment);
	part2 = Dvvvv(func,3.0*q1-q4,x0,p,n,increment);
	part3 = Dvvvv(func,q1+q4,x0,p,n,increment);
	part4 = Dvvvv(func,q1-q4,x0,p,n,increment);
	vec4 = (part1 - part2 - 3.0*part3 + 3.0*part4)/192.0;
      end
    elseif (q3==q4)
      part1 = Dvvvv(func,q1+q3,x0,p,n,increment);
      part2 = Dvvvv(func,q1-q3,x0,p,n,increment);
      part3 = Dvvvv(func,q1,x0,p,n,increment);
      part4 = Dvvvv(func,q3,x0,p,n,increment);
      vec4 = (part1 + part2 - 2.0*part3 - 2.0*part4)/12.0;
    else
      part1 = Dvvvv(func,2.0*q1+q3+q4,x0,p,n,increment);
      part2 = Dvvvv(func,2.0*q1+q3-q4,x0,p,n,increment);
      part3 = Dvvvv(func,2.0*q1-q3+q4,x0,p,n,increment);
      part4 = Dvvvv(func,2.0*q1-q3-q4,x0,p,n,increment);
      part5 = Dvvvv(func, q3+q4,x0,p,n,increment);
      part6 = Dvvvv(func,-q3+q4,x0,p,n,increment);
      vec4 = (part1 - part2 - part3 + part4 - 2.0*part5 + 2.0*part6)/192.0;
    end    
  else
    part1 = Dvvvv(func,q1+q2+q3+q4,x0,p,n,increment);
    part2 = Dvvvv(func,q1+q2+q3-q4,x0,p,n,increment);
    part3 = Dvvvv(func,q1+q2-q3+q4,x0,p,n,increment);
    part4 = Dvvvv(func,q1+q2-q3-q4,x0,p,n,increment);
    part5 = Dvvvv(func,q1-q2+q3+q4,x0,p,n,increment);
    part6 = Dvvvv(func,q1-q2+q3-q4,x0,p,n,increment);
    part7 = Dvvvv(func,q1-q2-q3+q4,x0,p,n,increment);
    part8 = Dvvvv(func,q1-q2-q3-q4,x0,p,n,increment);
    vec4 = (part1 - part2 - part3 + part4 - part5 + part6 + part7 - part8)/192.0;
  end
end
%----------------------------------------------------
function tempvec = Dvvvv(func,vq,x0,p,n,increment)
  f0 = x0;
  f1 = x0 + 4.0*increment*vq;
  f2 = x0 + 2.0*increment*vq;
  f3 = x0 - 2.0*increment*vq;
  f4 = x0 - 4.0*increment*vq;
  for i=1:n
      f0 = feval(func, 0, f0, p{:});
      f1 = feval(func, 0, f1, p{:});
      f2 = feval(func, 0, f2, p{:});
      f3 = feval(func, 0, f3, p{:});
      f4 = feval(func, 0, f4, p{:});    
  end
  tempvec = (f1 - 4.0*f2 + 6.0*f0 - 4.0*f3 + f4)/(16.0*increment^4);
