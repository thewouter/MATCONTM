function coef = nf_LPPDm(mapsf,mapsJ,mapsH,mapsDer3,A,q0,p0,q1,p1,nphase,x0,p,n)
%
% coef = nf_LPPDm(mapsf,mapsJ,mapsH,mapsDer3,A,q0,p0,q1,p1,nphase,x0,p,n)
% compute (hyper-)normalform coefficient for the fold-flip bifurcation
% q0,p0 for fold, q1,p1 for flip.
%
global cds T1global T2global T3global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  if (cds.options.SymDerivative >= 3)
    T1global=tens1(mapsf,mapsJ,x0,p,n);
    T2global=tens2(mapsf,mapsH,x0,p,n);
    T3global=tens3(mapsf,mapsDer3,x0,p,n);
  end
  h20 = multilinear2(mapsf,q0,q0,x0,p,n,hessIncrement);        			%  B(q0,q0)
  h11 = multilinear2(mapsf,q0,q1,x0,p,n,hessIncrement);        			%  B(q0,q1)
  h02 = multilinear2(mapsf,q1,q1,x0,p,n,hessIncrement);        			%  B(q1,q1)
  a1 = p0'*h20;
  e1 = p1'*h11;
  b1 = p0'*h02;
  h20 = [eye(nphase)-A q0 ; p0' 0]\[(p0'*h20)*q0-h20; 0];
  h11 = [eye(nphase)+A q1 ; p1' 0]\[(p1'*h11)*q1-h11; 0];
  h02 = [eye(nphase)-A q0 ; p0' 0]\[(p0'*h02)*q0-h02; 0];
  h20 = h20(1:nphase);h11 = h11(1:nphase);h02 = h02(1:nphase);
  c1 = multilinear3(mapsf,q0,q0,q0,x0,p,n,ten3Increment);			%   C(q0,q0,q0)
  c1 = p0'*(c1 + 3.0*multilinear2(mapsf,q0,h20,x0,p,n,hessIncrement));  	% +3B(q,h20)
  c2 = multilinear3(mapsf,q0,q1,q1,x0,p,n,ten3Increment);			%   C(q0,q1,q1)
  c2 = c2 + multilinear2(mapsf,q0,h02,x0,p,n,hessIncrement);			% + B(q0,h02)
  c2 = p0'*(c2 + 2.0*multilinear2(mapsf,q1,h11,x0,p,n,hessIncrement));		% +2B(q1,h11)
  c3 = multilinear3(mapsf,q0,q0,q1,x0,p,n,ten3Increment);			%   C(q0,q0,q1)
  c3 = c3 + multilinear2(mapsf,q1,h20,x0,p,n,hessIncrement);			% + B(q1,h20)
  c3 = p1'*(c3 + 2.0*multilinear2(mapsf,q0,h11,x0,p,n,hessIncrement));		% +2B(q0,h11)
  c4 = multilinear3(mapsf,q1,q1,q1,x0,p,n,ten3Increment);			%   C(q1,q1,q1)
  c4 = p1'*(c4 + 3.0*multilinear2(mapsf,q1,h02,x0,p,n,hessIncrement));		% +3B(q1,h02)
  coef = [ a1/e1/2 b1*e1/2 c1/e1/e1/6 (c2/2 +(b1*c3-c4*(a1+e1)/3)/e1)];
 %If necessary: Next line computes the nondegeneracy of NS bifurcation of double period
 CNS= coef(2)*coef(3)/3 - coef(1)*(coef(1)*coef(2)/2 + 3*coef(2) + coef(4));
 coef = [coef(1) coef(2) CNS]; 
 %coef = [coef(1) coef(2)]; 
 clear T1global T2global T3global;


