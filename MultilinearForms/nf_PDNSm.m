function coef = nf_PDNSm(mapsf,mapsJ,mapsH,mapsDer3,A,vext1,wext1,vext2,wext2,nphase,x0,p,n)
%
% coef = nf_PDNSm(mapsf,mapsJ,mapsH,mapsDer3,A,vext1,wext1,vext2,wext2,nphase,x0,p,n)
% Computes normalform coefficients for a PDNS-bifurcation. returns coefficients of an
% amplitude map. vext1 is PD-vector, vext2 is NS-vector.
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
  ev = wext2'*A*vext2;									%This is the complex eigenvalue
%----2nd order vectors
  h200 = (eye(nphase)-A)\multilinear2(mapsf,vext1,vext1,x0,p,n,hessIncrement);		%   (I-A)\B(q1,q1)
  h011 = (eye(nphase)-A)\multilinear2(mapsf,vext2,conj(vext2),x0,p,n,hessIncrement);	%   (I-A)\B(q2,bar(q2))
  h020 = (ev*ev*eye(nphase)-A)\multilinear2(mapsf,vext2,vext2,x0,p,n,hessIncrement);	%   (ev^2*I-A)\B(q2,q2)
  h110 = -(ev*eye(nphase)+A)\multilinear2(mapsf,vext1,vext2,x0,p,n,hessIncrement);	%   -(A+ev*I)\B(q1,q2)
%----3rd order vectors
  h300 = multilinear3(mapsf,vext1,vext1,vext1,x0,p,n,ten3Increment);			%   C(q1,q1,q1)
  h300 = h300 + 3.0*multilinear2(mapsf,vext1,h200,x0,p,n,hessIncrement);  % +3B(q1,h200)
  h111 = multilinear3(mapsf,vext1,vext2,conj(vext2),x0,p,n,ten3Increment);  %   C(q1,q2,bar(q2))
  h111 = h111 + 2.0*real(multilinear2(mapsf,h110,vext2,x0,p,n,hessIncrement));		% +2Re(B(q2,h101))
  h111 = h111 + multilinear2(mapsf,vext1,h011,x0,p,n,hessIncrement);			% + B(q1,h011)
  h210 = multilinear3(mapsf,vext1,vext1,vext2,x0,p,n,ten3Increment);			%   C(q1,q1,q2)
  h210 = h210 + 2.0*multilinear2(mapsf,vext1,h110,x0,p,n,hessIncrement);		% +2B(q1,h110)
  h210 = h210 + multilinear2(mapsf,vext2,h200,x0,p,n,hessIncrement);			% + B(q2,h200)
  h021 = multilinear3(mapsf,vext2,vext2,conj(vext2),x0,p,n,ten3Increment);		%   C(q2,q2,bar(q2))
  h021 = h021 + 2.0*multilinear2(mapsf,conj(vext2),h020,x0,p,n,hessIncrement);		% +2B(bar(q2),h020)
  h021 = h021 + multilinear2(mapsf,vext2,h011,x0,p,n,hessIncrement);			% + B(q2,h011)
%----coefficients and scaling  
  f300 = wext1'*h300/6.0;f111 = wext1'*h111;
  g210 = (wext2'*h210)/2.0;g021 = (wext2'*h021)/2.0; 
  coef = [-f300 -f111 real(conj(ev)*g210) real(conj(ev)*g021)];
  
clear T1global T2global T3global
 
