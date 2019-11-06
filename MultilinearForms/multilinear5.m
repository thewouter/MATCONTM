function vec5 = multilinear5(func,q1,q2,q3,q4,q5,x0,p,n,increment)
%--------------------------------------------------------------
%This file computes the multilinear function E(q1,q2,q3,q4,q5) where
%E = D^5(F(x0)), the fifth derivative of the map wrt to phase
%variables only. We use this for normal form computations in which we
%will have q1=q2=q3=q4=q5 or q1=q2=q3\neq q4=q5. We decide on these
%cases only. Otherwise we just compute the thing directly without
%optimization.
%--------------------------------------------------------------

global  cds
nphase=size(x0,1);
if ((cds.options.AutDerivative>0) && (n>=cds.options.AutDerivativeIte )) || ((cds.options.AutDerivative>0)&& (cds.options.SymDerivative <5))
    vec5=multilinear5AD(func,q1,q2,q3,q4,q5,x0,p,n);
    vec5=vec5(:,end); 
elseif (cds.options.SymDerivative >=5)
   vec5=multilinear5sym(q1,q2,q3,q4,q5,nphase,n);
else
 if (q1==q2 & q1 ==q3)
    if (q1==q4 & q1==q5)
        vec5 = Evvvvv(func,q1,x0,p,n,increment);
    else
        part1 = Evvvvv(func,3.0*q1+2.0*q4,x0,p,n,increment);
        part2 = Evvvvv(func,3.0*q1-2.0*q4,x0,p,n,increment);
        part3 = Evvvvv(func,3.0*q1,x0,p,n,increment);
        part4 = Evvvvv(func,q1,x0,p,n,increment);
        part5 = Evvvvv(func,q1+2.0*q4,x0,p,n,increment);
        part6 = Evvvvv(func,q1-2.0*q4,x0,p,n,increment);
        vec5 = (part1 + part2 - 2.0*part3 + 6.0*part4 - 3.0*part5 - 3.0*part6)/1920.0;
    end
  else
        part1 = Evvvvv(func,q1+q2+q3+q4+q5,x0,p,n,increment);
        part2 = Evvvvv(func,q1+q2+q3+q4-q5,x0,p,n,increment);
        part3 = Evvvvv(func,q1+q2+q3-q4-q5,x0,p,n,increment);
        part4 = Evvvvv(func,q1+q2+q3-q4+q5,x0,p,n,increment);
        part5 = Evvvvv(func,q1+q2-q3+q4+q5,x0,p,n,increment);
        part6 = Evvvvv(func,q1+q2-q3+q4-q5,x0,p,n,increment);
        part7 = Evvvvv(func,q1+q2-q3-q4-q5,x0,p,n,increment);
        part8 = Evvvvv(func,q1+q2-q3-q4+q5,x0,p,n,increment);
        vec5 = (part1 - part2 + part3 - part4 - part5 + part6 - part7 + part8)/1920.0;
        part1 = Evvvvv(func,q1-q2+q3+q4+q5,x0,p,n,increment);
        part2 = Evvvvv(func,q1-q2+q3+q4-q5,x0,p,n,increment);
        part3 = Evvvvv(func,q1-q2+q3-q4-q5,x0,p,n,increment);
        part4 = Evvvvv(func,q1-q2+q3-q4+q5,x0,p,n,increment);
        part5 = Evvvvv(func,q1-q2-q3+q4+q5,x0,p,n,increment);
        part6 = Evvvvv(func,q1-q2-q3+q4-q5,x0,p,n,increment);
        part7 = Evvvvv(func,q1-q2-q3-q4-q5,x0,p,n,increment);
        part8 = Evvvvv(func,q1-q2-q3-q4+q5,x0,p,n,increment);
        vec5 = vec5 - (part1 - part2 + part3 - part4 - part5 + part6 - part7 + part8)/1920.0;
  end
end
%----------------------------------------------------
function tempvec = Evvvvv(func,vq,x0,p,n,increment)
  f1 = x0 + 5.0*increment*vq;
  f2 = x0 + 3.0*increment*vq;
  f3 = x0 + 1.0*increment*vq;
  f4 = x0 - 1.0*increment*vq;
  f5 = x0 - 3.0*increment*vq;
  f6 = x0 - 5.0*increment*vq;
  for i=1:n
    f1 = feval(func, 0, f1, p{:});
    f2 = feval(func, 0, f2, p{:});
    f3 = feval(func, 0, f3, p{:});
    f4 = feval(func, 0, f4, p{:});
    f5 = feval(func, 0, f5, p{:});
    f6 = feval(func, 0, f6, p{:});
  end
 tempvec =  (f1 - 5.0*f2 + 10.0*f3 - 10.0*f4 + 5.0*f5 - f6)/(32.0*increment^5); 
