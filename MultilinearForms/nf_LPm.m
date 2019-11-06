function coef=nf_LPm(mapsf,mapsJ,mapsH,vext,wext,x,p,n)
%
% coef= nf_LPm(x0) = <p,B(q,q)> with normalized vectors
% compute normalform coefficient for a limitpoint bifurcation.
%
global cds T1global T2global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  if (cds.options.SymDerivative >= 2)
    T1global=tens1(mapsf,mapsJ,x,p,n);
    T2global=tens2(mapsf,mapsH,x,p,n);
  end
  Bqq = multilinear2(mapsf,vext,vext,x,p,n,hessIncrement); %B(q,q)
  coef = wext'*Bqq/2.0;
clear T1global T2global;
  
