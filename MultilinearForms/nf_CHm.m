function coef = nf_CHm(mapsf,mapsJ,mapsH,mapsDer3,mapsDer4,mapsDer5,A,vext,wext,nphase,x1,p1,n)
%                 
% nf_CHm(mapsf,mapsJ,mapsH,mapsDer3,mapsDer4,mapsDer5,A,vext,wext,nphase,x1,p1,n)
% compute the nondegeneracy condition for a Chenciner bifurcation.
%
global cds T1global T2global T3global T4global T5global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  ten4Increment =(cds.options.Increment)^(3.0/6.0);
  ten5Increment =(cds.options.Increment)^(3.0/7.0);
  if (cds.options.SymDerivative >= 5)
    T1global=tens1(mapsf,mapsJ,x1,p1,n);
    T2global=tens2(mapsf,mapsH,x1,p1,n);
    T3global=tens3(mapsf,mapsDer3,x1,p1,n);
    T4global=tens4(mapsf,mapsDer4,x1,p1,n);
    T5global=tens5(mapsf,mapsDer5,x1,p1,n);
  end
  d1 = wext'*A*vext;										%this is the complex eigenvalue
  h20 = multilinear2(mapsf,vext,vext,x1,p1,n,hessIncrement);					%  B(q,q)
  h20 = (d1*d1*eye(nphase)-A)\h20;
  h11 = multilinear2(mapsf,vext,conj(vext),x1,p1,n,hessIncrement);				%   B(q,bar(q))
  h11 = (eye(nphase)-A)\h11;
  h30 = multilinear3(mapsf,vext,vext,vext,x1,p1,n,ten3Increment);				%   C(q,q,q)
  h30 = h30 + 3.0*multilinear2(mapsf,vext,h20,x1,p1,n,hessIncrement);				% +3B(q,h20)
  h30 = (d1*d1*d1*eye(nphase)-A)\h30;
  h21 = multilinear3(mapsf,vext,vext,conj(vext),x1,p1,n,ten3Increment);				%   C(q,q,bar(q))
  h21 = h21 + 2*multilinear2(mapsf,vext,h11,x1,p1,n,hessIncrement);				% +2B(q,h11)
  h21 = h21 + multilinear2(mapsf,conj(vext),h20,x1,p1,n,hessIncrement);				% + B(bar(q),h20)
  c1 = (wext'*h21)/2.0;
  h21 = [A-d1*eye(nphase) vext ; wext' 0]\[(wext'*h21)*vext - h21; 0];
  h21 = h21(1:nphase);
%----Fourth order terms------------------------------------------------
  h31 = multilinear4(mapsf,vext,vext,vext,conj(vext),x1,p1,n,ten4Increment);			%   D(q,q,q,bar(q))
  h31 = h31 + 3.0*multilinear3(mapsf,vext,conj(vext),h20,x1,p1,n,ten3Increment); 		% +3C(q,bar(q),h20)
  h31 = h31 + 3.0*multilinear3(mapsf,vext,vext,h11,x1,p1,n,ten3Increment); 			% +3C(q,q,h11)
  h31 = h31 + 3.0*multilinear2(mapsf,vext,h21,x1,p1,n,ten3Increment);  				% +3B(q,h21)
  h31 = h31 + 3.0*multilinear2(mapsf,h11,h20,x1,p1,n,hessIncrement);  				% +3B(h20,h11)
  h31 = h31 + multilinear2(mapsf,conj(vext),h30,x1,p1,n,hessIncrement);  			% + B(bar(q),h30)
  h31 = (d1*d1*eye(nphase)-A)\(h31-6*h20*c1*d1);
  h22 = multilinear4(mapsf,vext,vext,conj(vext),conj(vext),x1,p1,n,ten4Increment);		%   D(q,q,bar(q),bar(q))
  h22 = h22 + multilinear3(mapsf,vext,vext,conj(h20),x1,p1,n,ten3Increment);			% + C(q,q,h02)
  h22 = h22 + multilinear3(mapsf,conj(vext),conj(vext),h20,x1,p1,n,ten3Increment);		% + C(bar(q),bar(q),h20)
  h22 = h22 + 4.0*multilinear3(mapsf,vext,conj(vext),h11,x1,p1,n,ten3Increment); 		% +4C(q,bar(q),h11)
  h22 = h22 + multilinear2(mapsf,h20,conj(h20),x1,p1,n,hessIncrement);  			% + B(h20,h02)
  h22 = h22 + 2.0*multilinear2(mapsf,h11,h11,x1,p1,n,hessIncrement);  				% +2B(h11,h11) 
  h22 = h22 + 2.0*multilinear2(mapsf,conj(vext),h21,x1,p1,n,hessIncrement); 			% +2B(bar(q),h21)
  h22 = h22 + 2.0*multilinear2(mapsf,vext,conj(h21),x1,p1,n,hessIncrement); 			% +2B(q,h12)
  h22 = (eye(nphase)-A)\h22;
%----Fifth order terms-------------------------------------------------
  h32 = multilinear5(mapsf,vext,vext,vext,conj(vext),conj(vext),x1,p1,n,ten5Increment);		%   E(q,q,q,bar(q),bar(q))
  h32 = h32 + multilinear4(mapsf,vext,vext,vext,conj(h20),x1,p1,n,ten4Increment);		% + D(q,q,q,h02)
  h32 = h32 + 6.0*multilinear4(mapsf,vext,vext,conj(vext),h11,x1,p1,n,ten4Increment);		% +6D(q,q,bar(q),h11)
  h32 = h32 + 3.0*multilinear4(mapsf,vext,conj(vext),conj(vext),h20,x1,p1,n,ten4Increment);	% +3D(q,bar(q),bar(q),h20)
  h32 = h32 + 6.0*multilinear3(mapsf,h11,h11,vext,x1,p1,n,ten3Increment);  			% +6C(h11,h11,q)
  h32 = h32 + 6.0*multilinear3(mapsf,vext,conj(vext),h21,x1,p1,n,ten3Increment);		% +6C(q,bar(q),h21)
  h32 = h32 + 6.0*multilinear3(mapsf,conj(vext),h11,h20,x1,p1,n,ten3Increment);			% +6C(bar(q),h11,h20)
  
  h32 = h32 + 3.0*multilinear3(mapsf,vext,h20,conj(h20),x1,p1,n,ten3Increment);			% +3C(q,h20,h02)
  h32 = h32 + 3.0*multilinear3(mapsf,vext,vext,conj(h21),x1,p1,n,ten3Increment);		% +3C(q,q,h12)
  h32 = h32 + multilinear3(mapsf,conj(vext),conj(vext),h30,x1,p1,n,ten3Increment);		% + C(bar(q),bar(q),h30)
  h32 = h32 + 6.0*multilinear2(mapsf,h11,h21,x1,p1,n,hessIncrement);				% +6B(h11,h21)
  h32 = h32 + 3.0*multilinear2(mapsf,h20,conj(h21),x1,p1,n,hessIncrement);			% +3B(h20,h12)
  h32 = h32 + 3.0*multilinear2(mapsf,vext,h22,x1,p1,n,hessIncrement);				% +3B(q,h22)
  h32 = h32 + 2.0*multilinear2(mapsf,conj(vext),h31,x1,p1,n,hessIncrement);			% +2B(bar(q),h31)
  h32 = h32 + multilinear2(mapsf,conj(h20),h30,x1,p1,n,hessIncrement);	  % + B(h02,h30)
  c2 = (wext'*h32)/12.0;
  coef = conj(d1)*c2 - (conj(d1)*c1)^2/2; 
  
clear T1global T2global T3global T4global T5global
