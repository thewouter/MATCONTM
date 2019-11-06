function [coef,D1] = nf_R4m(mapsf,mapsJ,mapsH,mapsDer3,A,vext,wext,nphase,x0,p,n)
%
% [coef,d] = nf_R4m(mapsf,mapsJ,mapsH,mapsDer3,A,vext,wext,nphase,x0,p,n)
% compute 1:4 Resonance normalform coefficients, and return the nondegeneracy
% condition of the flow approximation.
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
  h20 = multilinear2(mapsf,vext,vext,x0,p,n,hessIncrement); 				%B(q,q)
  h20 = -(A+eye(nphase))\h20;
  h11 = multilinear2(mapsf,vext,conj(vext),x0,p,n,hessIncrement); 			%B(q,bar(q))
  h11 = (eye(nphase)-A)\h11;
  h21 = multilinear3(mapsf,vext,vext,conj(vext),x0,p,n,ten3Increment);			%   C(q,q,bar(q))
  h21 = h21 + multilinear2(mapsf,conj(vext),h20,x0,p,n,hessIncrement);			% + B(bar(q),h20)
  h21 = h21 + 2.0*multilinear2(mapsf,vext,h11,x0,p,n,hessIncrement);			% +2B(q,h11)
  h03 = multilinear3(mapsf,conj(vext),conj(vext),conj(vext),x0,p,n,ten3Increment);	%   C(bar(q),bar(q),bar(q))
  h03 = h03 + 3.0*multilinear2(mapsf,conj(vext),conj(h20),x0,p,n,hessIncrement);	% +3B(bar(q),h02)
  C1 = wext'*h21/2.0;D1 = wext'*h03/6.0;
  coef = [real(-i*C1/abs(D1)) imag(-i*C1/abs(D1))];
clear T1global T2global T3global
