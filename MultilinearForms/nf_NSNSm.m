function coef = nf_NSNSm(mapsf,mapsJ,mapsH,mapsDer3,A,vext1,wext1,vext2,wext2,nphase,x0,p,n)
%
% coef = nf_NSNSm(mapsf,mapsJ,mapsH,mapsDer3,A,vext1,wext1,vext2,wext2,nphase,x0,p,n)
% Computes normalform coefficients for a double NS-bifurcation and returns coefficients
% of an amplitude map. vext1 is for phi1, vext2 is for phi2.
%
global cds T1global T2global T3global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  if (cds.options.SymDerivative >= 3)
    T1global=tens1(mapsf,mapsJ,x0,p,n);
    T2global=tens2(mapsf,mapsH,x0,p,n);
    T3global=tens3(mapsf,mapsDer3,x0,p,n);
  end
  ev1 = wext1'*A*vext1;ev2 = wext2'*A*vext2;						%These are the complex eigenvalues.
%----2nd order vectors
  h2000 = (ev1*ev1*eye(nphase)-A)\multilinear2(mapsf,vext1,vext1,x0,p,n,hessIncrement);			% (ev1^2*I-A)\B(q1,q1)
  h1100 = (eye(nphase)-A)\multilinear2(mapsf,vext1,conj(vext1),x0,p,n,hessIncrement);			% (I-A)\B(q1,bar(q1))
  h1010 = (ev1*ev2*eye(nphase)-A)\multilinear2(mapsf,vext1,vext2,x0,p,n,hessIncrement);			% (ev1*ev2*I-A)\B(q2,q2)
  h1001 = (ev1*conj(ev2)*eye(nphase)-A)\multilinear2(mapsf,vext1,conj(vext2),x0,p,n,hessIncrement);	% (ev1*bar(ev2)*I-A)\B(q1,bar(q2))
  h0020 = (ev2*ev2*eye(nphase)-A)\multilinear2(mapsf,vext2,vext2,x0,p,n,hessIncrement);			% (ev2^2*I-A)\B(q2,q2)
  h0011 = (eye(nphase)-A)\multilinear2(mapsf,vext2,conj(vext2),x0,p,n,hessIncrement);			% (I-A)\B(q2,bar(q2))
%----3rd order
  h2100 = multilinear3(mapsf,vext1,vext1,conj(vext1),x0,p,n,ten3Increment);				%   C(q1,q1,bar(q1))
  h2100 = h2100 + 2.0*multilinear2(mapsf,conj(vext1),h2000,x0,p,n,hessIncrement);			% +2B(bar(q1),h2000)
  h2100 = h2100 + multilinear2(mapsf,vext1,h1100,x0,p,n,hessIncrement);					% + B(q1,h1100)
  h1011 = multilinear3(mapsf,vext1,vext2,conj(vext2),x0,p,n,ten3Increment);				%   C(q1,q1,bar(q1))
  h1011 = h1011 + multilinear2(mapsf,vext1,h0011,x0,p,n,hessIncrement);					% + B(q1,h0011)
  h1011 = h1011 + multilinear2(mapsf,vext2,h1001,x0,p,n,hessIncrement);					% + B(q2,h1001)  
  h1011 = h1011 + multilinear2(mapsf,conj(vext2),h1010,x0,p,n,hessIncrement);				% + B(bar(q2),h1010)  
  h1110 = multilinear3(mapsf,vext2,vext1,conj(vext1),x0,p,n,ten3Increment);				%   C(q2,q1,bar(q1))
  h1110 = h1110 + multilinear2(mapsf,vext2,h1100,x0,p,n,hessIncrement);					% + B(q2,h1100)  
  h1110 = h1110 + multilinear2(mapsf,vext1,conj(h1001),x0,p,n,hessIncrement);				% + B(q1,h0110)  
  h1110 = h1110 + multilinear2(mapsf,conj(vext1),h1010,x0,p,n,hessIncrement);				% + B(bar(q1),h1010)
  h0021 = multilinear3(mapsf,vext2,vext2,conj(vext2),x0,p,n,ten3Increment);				%   C(q2,q2,bar(q2))
  h0021 = h0021 + 2.0*multilinear2(mapsf,conj(vext2),h0020,x0,p,n,hessIncrement);			% +2B(bar(q2),h0020)
  h0021 = h0021 + multilinear2(mapsf,vext2,h0011,x0,p,n,hessIncrement);					% + B(q2,h0011)
%----coefficients and scaling  
  c1 = (wext1'*h2100)/2; c2 = (wext1'*h1011)/2;
  c3 = (wext2'*h1110)/2; c4 = (wext2'*h0021)/2;
  a11 = real(conj(ev1)*c1); a12 = real(conj(ev1)*c2);
  a21 = real(conj(ev2)*c3); a22 = real(conj(ev2)*c4);
  coef = [a11 a12 a21 a22];
clear T1global T2global T3global
