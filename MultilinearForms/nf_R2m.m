function coef = nf_R2m(mapsf,mapsJ,mapsH,mapsDer3,A,vext,genvext,wext,genwext,nphase,x0,p,n)
%               
% coef = nf_R2m(mapsf,mapsJ,mapsH,mapsDer3,A,vext,genvext,wext,genwext,nphase,x0,p,n)
% compute 1:2 Resonance normalform coefficients, and return nondegeneracy conditions of the flow.
%
global cds T1global T2global T3global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  if (cds.options.SymDerivative >= 1)
    T1global=tens1(mapsf,mapsJ,x0,p,n);
  end
  if (cds.options.SymDerivative >= 2)
    T2global=tens2(mapsf,mapsH,x0,p,n);
  end
  if (cds.options.SymDerivative >= 3)
    T3global=tens3(mapsf,mapsDer3,x0,p,n);
  end
  h20 = multilinear2(mapsf,vext,vext,x0,p,n,hessIncrement);		%   B(q0,q0)
  h11 = multilinear2(mapsf,vext,genvext,x0,p,n,hessIncrement); 		%   B(q0,q1)
  h20 = (eye(nphase)-A)\h20;
  h11 = (eye(nphase)-A)\(h11+h20);
  h30 = multilinear3(mapsf,vext,vext,vext,x0,p,n,ten3Increment);	%   C(q0,q0,q0)
  h30 = h30 + 3.0*multilinear2(mapsf,vext,h20,x0,p,n,hessIncrement);	% +3B(q,h2)
  h21 = multilinear3(mapsf,vext,vext,genvext,x0,p,n,ten3Increment);	%   C(q0,q0,q1)
  h21 = h21 + multilinear2(mapsf,genvext,h20,x0,p,n,hessIncrement);	% + B(q1,h20)
  h21 = h21 + 2.0*multilinear2(mapsf,vext,h11,x0,p,n,hessIncrement);  % +2B(q0,h11)
  %[C1,D1] = [wext'*h30/6.0 (wext'*h21 + genwext'*h30)/2.0],pause
  C1 = wext'*h30/6.0; 
  D1=(wext'*h21 + genwext'*h30)/2.0;
  coef = [4*C1 (-2*D1-6*C1)];
clear T1global T2global T3global
