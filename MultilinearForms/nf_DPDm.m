function coef = nf_DPDm(mapsf,mapsJ,mapsH,mapsDer3,mapsDer4,mapsDer5,A,vext,wext,nphase,x0,p,n)
%
% coef= nf_DPDm(mapsf,mapsJ,mapsH,mapsDer3,mapsDer4,mapsDer5,A,vext,wext,nphase,x0,p,n) 
% compute normal form coefficient for degenerate flip
%
global cds T1global T2global T3global T4global T5global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  ten4Increment =(cds.options.Increment)^(3.0/6.0);
  ten5Increment =(cds.options.Increment)^(3.0/7.0);
  if (cds.options.SymDerivative >= 1)
    T1global=tens1(mapsf,mapsJ,x0,p,n);
  end
  if (cds.options.SymDerivative >= 2)
    T2global=tens2(mapsf,mapsH,x0,p,n);
  end
  
  if (cds.options.SymDerivative >= 3)
    T3global=tens3(mapsf,mapsDer3,x0,p,n);
  end
  if (cds.options.SymDerivative >= 4)
    T4global=tens4(mapsf,mapsDer4,x0,p,n);
  end
  if (cds.options.SymDerivative >= 5)
    T5global=tens5(mapsf,mapsDer5,x0,p,n);
  end
  h2 = multilinear2(mapsf,vext,vext,x0,p,n,hessIncrement);       			%B(q,q)
  h2 = (eye(nphase)-A)\h2;                                          			%h2 = (I-A)^{INV}B(q,q)
  RHS3 = multilinear3(mapsf,vext,vext,vext,x0,p,n,ten3Increment);			%   C(q,q,q)
  RHS3 = RHS3 + 3.0*multilinear2(mapsf,vext,h2,x0,p,n,hessIncrement);   		% +3B(q,h2)
  a = wext'*RHS3/6.0;
  h3 = [A + eye(nphase) vext ; wext' 0]\[6.0*a*vext - RHS3; 0];
  h3 = h3(1:nphase);
%----Fourth order terms------------------------------------------------
  RHS4 =  multilinear4(mapsf,vext,vext,vext,vext,x0,p,n,ten4Increment);		% + D(q,q,q,q)
  RHS4 = RHS4 + 6.0*multilinear3(mapsf,vext,vext,h2,x0,p,n,ten3Increment);		% +6C(q,q,h2)
  RHS4 = RHS4 + 4.0*multilinear2(mapsf,vext,h3,x0,p,n,hessIncrement);           	% +4B(q,h3)
  RHS4 = RHS4 + 3.0*multilinear2(mapsf,h2,h2,x0,p,n,hessIncrement);    			% +3B(h2,h2)
  h4 = (eye(nphase)-A)\RHS4;
%----Fifth order terms------------------------------------------------
  RHS5 = multilinear5(mapsf,vext,vext,vext,vext,vext,x0,p,n,ten5Increment);	% +E(q,q,q,q,q)
  RHS5 = RHS5 +10.0*multilinear4(mapsf,vext,vext,vext,h2,x0,p,n,ten4Increment);		% +10D(q,q,q,h2);
  RHS5 = RHS5 +15.0*multilinear3(mapsf,h2,h2,vext,x0,p,n,ten3Increment);		% +15C(h2,h2,q)
  RHS5 = RHS5 +10.0*multilinear3(mapsf,vext,vext,h3,x0,p,n,ten3Increment);		% +10C(q,q,h3)
  RHS5 = RHS5 +10.0*multilinear2(mapsf,h2,h3,x0,p,n,hessIncrement);			% +10B(h2,h3)
  RHS5 = RHS5 + 5.0*multilinear2(mapsf,vext,h4,x0,p,n,hessIncrement);			% +5B(q,h4)
  coef = wext'*(RHS5)/120;
clear T1global T2global T3global T4global T5global
