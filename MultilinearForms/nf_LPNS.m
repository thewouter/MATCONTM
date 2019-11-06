function coef = nf_LPNSm(mapfile,mapsJ,mapsH,mapsDer3,A,vext1,wext1,vext2,wext2,nphase,x0,p,n)
%
% Computes normalform coefficients for a LPNS-bifurcation. Will reduce to hypernormalform.
% vext1 is LP-vector, vext2 is NS-vector.
%
global cds T1global T2global T3global T4global T5global
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/6.0);
if (cds.options.SymDerivative >= 3)
     T1global=tens1(mapfile,mapsJ,x0,p,n);
     T2global=tens2(mapfile,mapsH,x0,p,n);
     T3global=tens3(mapfile,mapsDer3,x0,p,n);
end
ev = wext2'*A*vext2;			%This is the complex eigenvalue
% 2nd order vectors and coefficients
  h200 = multilinear2(mapfile,vext1,vext1,x0,p,n,hessIncrement);
  h011 = multilinear2(mapfile,vext2,conj(vext2),x0,p,n,hessIncrement);
  h020 = multilinear2(mapfile,vext2,vext2,x0,p,n,hessIncrement);
  h110 = multilinear2(mapfile,vext1,vext2,x0,p,n,hessIncrement);
  f200 = wext1'*h200/2.0;f011 = wext1'*h011;g110 = wext2'*h110;
  %h200 = [A-eye(nphase) vext1; wext1' 0]\(2*f200*vext1-h200);
  h200 = [A-eye(nphase) vext1; wext1' 0]\[(2*f200*vext1-h200);0];%R
  h200=h200(1:nphase);%R
  %h011 = [A-eye(nphase) vext1; wext1' 0]\(  f011*vext1-h011);
  h011 = [A-eye(nphase) vext1; wext1' 0]\[(  f011*vext1-h011);0]; %R
  h011=h011(1:nphase);%R
  %h110 = [A-ev*eye(nphase) vext2; wext2' 0]\(g110*vext2-h110);
  h110 = [A-ev*eye(nphase) vext2; wext2' 0]\[(g110*vext2-h110);0];
  h110=h110(1:nphase);%R
  h020 = -(A-ev*ev*eye(nphase))\h020;
% 3rd order vectors and coefficients
  h300 = multilinear3(mapfile,vext1,vext1,vext1,x0,p,n,ten3Increment);
  h300 = h300 + 3.0*multilinear2(mapfile,vext1,h200,x0,p,n,hessIncrement);
  h111 = multilinear3(mapfile,vext1,vext2,conj(vext2),x0,p,n,ten3Increment);
  h111 = h111 + multilinear2(mapfile,vext1,h011,x0,p,n,hessIncrement);
  h111 = h111 + 2.0*real(multilinear2(mapfile,h110,conj(vext2),x0,p,n,hessIncrement));
  h210 = multilinear3(mapfile,vext1,vext1,vext2,x0,p,n,ten3Increment);
  h210 = h210 + multilinear2(mapfile,vext2,h200,x0,p,n,hessIncrement);
  h210 = h210 + 2.0*multilinear2(mapfile,vext1,h110,x0,p,n,hessIncrement);
  h021 = multilinear3(mapfile,vext2,vext2,conj(vext2),x0,p,n,ten3Increment);
  h021 = h021 + multilinear2(mapfile,vext2,h011,x0,p,n,hessIncrement);
  h021 = h021 + 2.0*multilinear2(mapfile,conj(vext2),h020,x0,p,n,hessIncrement);
  f300 = wext1'*h300/6.0;f111 = wext1'*h111;
  g210 = wext2'*h210/2.0;g021 = wext2'*h021/2.0;
  g110=wext2'*multilinear2(mapfile,vext1,vext2,x0,p,n,hessIncrement);
% coefficients with hypernormalization
% the coefficients g011 and g102 were not defined %% reza
  a=g011/f200
  c = f300/(f200^2); s = sign(f200*f011);
  b = (f011*g102 + g110*(f111/2.0 + real(conj(ev)*g021))-f200*g021*conj(ev))/(f011*f200^2);
  coef = [s a b c];
end
clear T1global T2global T3global ;
