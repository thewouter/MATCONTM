function [coef,C02,B1] = nf_R3m(mapsf,mapsJ,mapsH,mapsDer3,A,vext,wext,nphase,x0,p,n)
%
% coef = nf_R3m(mapsf,mapsJ,mapsH,mapsDer3,A,vext,wext,nphase,x0,p,n)
% compute 1:3 Resonance normalform coefficients, and returns nondegeneracy
% condition for the flow approximation.
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
  ev = wext'*A*vext;								%this is the complex eigenvalue
  h02 = multilinear2(mapsf,conj(vext),conj(vext),x0,p,n,hessIncrement); 	%   B(bar(q),bar(q))
  B1 = wext'*h02/2.0;
  
  h02 = [A-ev*eye(nphase) vext; wext' 0]\[(2*B1*vext-h02) ; 0];
  h02 = h02(1:nphase);
  h11 = multilinear2(mapsf,vext,conj(vext),x0,p,n,hessIncrement); 		%   B(q,bar(q))
  h11 = (eye(nphase)-A)\h11;
  h21 = multilinear3(mapsf,vext,vext,conj(vext),x0,p,n,ten3Increment);		%   C(q,q,bar(q))
  h21 = h21 + multilinear2(mapsf,conj(vext),conj(h02),x0,p,n,hessIncrement);	% + B(bar(q),h20)
  h21 = h21 + 2.0*multilinear2(mapsf,vext,h11,x0,p,n,hessIncrement);		% +2B(q,h11)
  C1 = wext'*h21/2.0;
  C0 = [real(ev*ev*C1/(B1*conj(B1)) - 1)/3 imag(ev*ev*C1/(B1*conj(B1))- 1)/3];
  coef = C0(1);
  C02=C0(2);
clear T1global T2global T3global
