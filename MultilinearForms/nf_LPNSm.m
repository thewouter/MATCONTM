function coef = nf_LPNSm(mapsf,mapsJ,mapsH,mapsDer3,A,vext1,wext1,vext2,wext2,nphase,x0,p,n)
%
% Computes normalform coefficients for a LPNS-bifurcation. Will reduce to hypernormalform.
% vext1 is LP-vector, vext2 is NS-vector.
%
global cds T1global T2global T3global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  if (cds.options.SymDerivative >= 3)
    T1global=tens1(mapsf,mapsJ,x0,p,n);
    T2global=tens2(mapsf,mapsH,x0,p,n);
    T3global=tens3(mapsf,mapsDer3,x0,p,n);
  end
  ev = wext2'*A*vext2;			%This is the complex eigenvalue
%----2nd order vectors and coefficients
  h200 = multilinear2(mapsf,vext1,vext1,x0,p,n,hessIncrement);				%   B(q1,q1)
  h110 = multilinear2(mapsf,vext1,vext2,x0,p,n,hessIncrement);				%   B(q1,q2)
  h020 = multilinear2(mapsf,vext2,vext2,x0,p,n,hessIncrement);				%   B(q2,q2)
  h011 = multilinear2(mapsf,vext2,conj(vext2),x0,p,n,hessIncrement);			%   B(q2,bar(q2))
  f200 = wext1'*h200/2.0;f011 = wext1'*h011;g110 = wext2'*h110;
  h200 = [A-eye(nphase) vext1; wext1' 0]\[(2*f200*vext1-h200);0];
  h011 = [A-eye(nphase) vext1; wext1' 0]\[(  f011*vext1-h011);0];
  h110 = [A-ev*eye(nphase) vext2; wext2' 0]\[(g110*vext2-h110);0];
  h200 = h200(1:nphase);h110 = h110(1:nphase); h011 = h011(1:nphase);
  h020 = (ev*ev*eye(nphase)-A)\h020;
%----3rd order vectors and coefficients
  h300 = multilinear3(mapsf,vext1,vext1,vext1,x0,p,n,ten3Increment);			%   C(q1,q1,q1)
  h300 = h300 + 3.0*multilinear2(mapsf,vext1,h200,x0,p,n,hessIncrement);		% +3B(q1,h200)
  h111 = multilinear3(mapsf,vext1,vext2,conj(vext2),x0,p,n,ten3Increment);		%   C(q1,q2,bar(q2))
  h111 = h111 + 2.0*real(multilinear2(mapsf,h110,conj(vext2),x0,p,n,hessIncrement));	% +2Re(B(h110,bar(q2)))
  h111 = h111 + multilinear2(mapsf,vext1,h011,x0,p,n,hessIncrement);			% + B(q1,h011)
  h210 = multilinear3(mapsf,vext1,vext1,vext2,x0,p,n,ten3Increment);			%   C(q1,q1,q2)
  h210 = h210 + 2.0*multilinear2(mapsf,vext1,h110,x0,p,n,hessIncrement);		% +2B(q1,h110)
  h210 = h210 + multilinear2(mapsf,vext2,h200,x0,p,n,hessIncrement);			% + B(q2,h200)
  h021 = multilinear3(mapsf,vext2,vext2,conj(vext2),x0,p,n,ten3Increment);		%   C(q2,q2,bar(q2))
  h021 = h021 + 2.0*multilinear2(mapsf,conj(vext2),h020,x0,p,n,hessIncrement);		% +2B(h020,bar(q2))
  h021 = h021 + multilinear2(mapsf,vext2,h011,x0,p,n,hessIncrement);			% + B(q2,h011)
  f300 = wext1'*h300/6.0;f111 = wext1'*h111;
  g210 = wext2'*h210/2.0;g021 = wext2'*h021/2.0;
%----coefficients with hypernormalization
  a = g110/f200; s = sign(f200*f011) ; c = f300/(f200^2);
  b = (f011*g210 + g110*(f111/2.0 + real(conj(ev)*g021))-f200*g021)/(f011*f200^2);
  coef = [s a b c];
clear T1global T2global T3global;
