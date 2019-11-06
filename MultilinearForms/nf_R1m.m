function coef = nf_R1m(mapsf,mapsJ,mapsH,A,vext,genvext,wext,genwext,nphase,x0,p,n)
%
% coef = nf_R1m(mapsf,mapsJ,mapsH,A,vext,genvext,wext,genwext,nphase,x0,p,n)
% compute R1 normal form coefficients. Then the coefficient s is computed
% and reported; This determines the stability of the involved invariant curve. 
%
global cds T1global T2global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  if (cds.options.SymDerivative >= 2)
    T1global=tens1(mapsf,mapsJ,x0,p,n);
    T2global=tens2(mapsf,mapsH,x0,p,n);
  end 
  h20 = multilinear2(mapsf,vext,vext,x0,p,n,hessIncrement);	%B(q0,q0)
  h11 = multilinear2(mapsf,vext,genvext,x0,p,n,hessIncrement);	%B(q0,q1)
  a = wext'*h20/2.0;						%b_20/2 !!
  b = wext'*h11+genwext'*h20;					%b_11
  coef = 2*a*(b-2*a);
  if (abs(coef) < 1e-13) coef = 0;
  else coef = sign(coef);
  end
clear T1global T2global
