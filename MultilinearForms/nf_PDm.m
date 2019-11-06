function coef=nf_PDm(mapsf,mapsJ,mapsH,mapsDer3,A,vext,wext,nphase,x0,p,n)
%
% coef = nf_PDm(x0) = <p,C(q,q,q) +3B(q,(A-I)^{INV}B(q,q))>
% compute normalform coefficient for a period-doubling bifurcation.
%

global cds T1global T2global T3global
hessIncrement =(cds.options.Increment)^(3.0/4.0);
ten3Increment =(cds.options.Increment)^(3.0/5.0);
if (cds.options.SymDerivative >= 2)
    T1global=tens1(mapsf,mapsJ,x0,p,n);
    T2global=tens2(mapsf,mapsH,x0,p,n);
end
if (cds.options.SymDerivative >= 3)
    T3global=tens3(mapsf,mapsDer3,x0,p,n);
end

h2 = (eye(nphase)-A)\multilinear2(mapsf,vext,vext,x0,p,n,hessIncrement);	%(I-A)\B(q,q)
RHS3 = multilinear3(mapsf,vext,vext,vext,x0,p,n,ten3Increment); 		% + C(q,q,q)
RHS3 = RHS3 + 3*multilinear2(mapsf,vext,h2,x0,p,n,hessIncrement);     % + 3*B(q,h2)
coef = wext'*RHS3/6.0;
clear T1global T2global T3global
