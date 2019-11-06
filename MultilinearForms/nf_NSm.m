 function coef=nf_NSm(mapsf,mapsJ,mapsH,mapsDer3,A,vext,wext,nphase,x1,p1,d1,n)
%                 
% coef=Re(d), d = nf_NSm(x0) = e^(-i*Theta)<p,C(q,q,conj(q))+2B(q,(A-I)^{INV}B(q,conj(q)))
%                +B(conj(q),e^(2i*Theta*I-A)^(INV)B(q,q)))>  with  normalized vectors
%
global cds T1global T2global T3global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  if (cds.options.SymDerivative >= 2)
    T1global=tens1(mapsf,mapsJ,x1,p1,n);
    T2global=tens2(mapsf,mapsH,x1,p1,n);
  end
  
  if (cds.options.SymDerivative >= 3)
    T3global=tens3(mapsf,mapsDer3,x1,p1,n);
  end
  d1 = wext'*A*vext;									%this is the complex eigenvalue
  h20 = (d1*d1*eye(nphase)-A)\multilinear2(mapsf,vext,vext,x1,p1,n,hessIncrement);	%   (d1^2*I-A)\B(q,q)
  h11 = (eye(nphase)-A)\multilinear2(mapsf,vext,conj(vext),x1,p1,n,hessIncrement);	%   (I-A)\B(q,bar(q))
  h21 = multilinear3(mapsf,vext,vext,conj(vext),x1,p1,n,ten3Increment);			%   C(q,q,bar(q))
  h21 = h21 + 2*multilinear2(mapsf,vext,h11,x1,p1,n,hessIncrement);			% +2B(q,h11)
  h21 = h21 +   multilinear2(mapsf,conj(vext),h20,x1,p1,n,hessIncrement);		% + B(bar(q),h20)
  coef = real(conj(d1)*(wext'*h21)/2.0);   
clear T1global T2global T3global;
