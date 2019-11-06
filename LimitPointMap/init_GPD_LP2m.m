function [x0,v0]= init_GPDm_LP2(mapfile,eps,x,p,ap,n,varargin)
% 
% [x0,v0]= init_DPDm_LP2(mapfile,eps,x,p,ap,n)
% Initializes a fold continuation from a degenerate flip point
%
global cds lpmds
% check input
if size(ap,2)~=2
  errordlg('Two active parameters are needed for a Limitpoint bifurcation curve continuation');
end
% initialize lpmds
lpmds.mapfile = mapfile;
func_handles = feval(lpmds.mapfile);
lpmds.func = func_handles{2};
lpmds.Jacobian  = func_handles{3};
lpmds.JacobianP = func_handles{4};
lpmds.Hessians  = func_handles{5};
lpmds.HessiansP = func_handles{6};
lpmds.Der3      = func_handles{7};
lpmds.Der4      = func_handles{8};
lpmds.Der5      = func_handles{9};
lpmds.Niterations=2*n;
siz = size(func_handles,2);
if siz > 9
  j=1;
  for i=10:siz
    lpmds.user{j}= func_handles{i};
    j=j+1;
  end
end
lpmds.nphase = size(x,1);
lpmds.ActiveParams = ap;
lpmds.P0 = p;
if size(varargin,1)>0,lpmds.BranchParams=varargin{1};else lpmds.BranchParams=[];end 
cds.curve = @limitpointmap;
cds.ndim = length(x)+2;
%-----Defining Symbolic derivatives-----
  symjac  = ~isempty(lpmds.Jacobian);
  symhes  = ~isempty(lpmds.Hessians);
  symDer3 = ~isempty(lpmds.Der3);
  symDer4 = ~isempty(lpmds.Der4);
  symDer5 = ~isempty(lpmds.Der5); 
  symord = 0; 
  if symjac, symord = 1; end
  if symhes, symord = 2; end
  if symDer3, symord = 3; end
  if symDer4, symord = 4; end
  if symDer5, symord = 5; end
  cds.options.SymDerivative = symord;
  symjacp  = ~isempty(lpmds.JacobianP); 
  symhessp = ~isempty(lpmds.HessiansP); 
  symordp = 0;
  if symjacp,  symordp = 1; end
  if symhessp, symordp = 2; end
  cds.options.SymDerivativeP = symordp;
%----------------------
p0 = p;p = n2c(p);
global T1global T2global T3global T4global T5global
if (cds.options.SymDerivative >=5)
  T1global=tens1(lpmds.func,lpmds.Jacobian,x,p,n);
  T2global=tens2(lpmds.func,lpmds.Hessians,x,p,n);
  T3global=tens3(lpmds.func,lpmds.Der3,x,p,n);
  T4global=tens4(lpmds.func,lpmds.Der4,x,p,n);
  T5global=tens5(lpmds.func,lpmds.Der5,x,p,n);   
end
  hessIncrement =(cds.options.Increment)^(3.0/4.0);
  ten3Increment =(cds.options.Increment)^(3.0/5.0);
  ten4Increment =(cds.options.Increment)^(3.0/6.0);
  ten5Increment =(cds.options.Increment)^(3.0/7.0);
%---Branch Switching Algorithm----
  nphase = size(x,1);
  A = lpmjac(x,p,n);
  [X,D] = eig(A+eye(nphase));
  [Y,i] = min(abs(diag(D)));
  vext = X(:,i)/norm(X(:,i));
  [X,D] = eig(A'+eye(nphase));
  [Y,i] = min(abs(diag(D)));
  wext = X(:,i)/(X(:,i)'*vext);
  c2 = nf_DPDm(lpmds.func,lpmds.Jacobian,lpmds.Hessians,lpmds.Der3,lpmds.Der4,lpmds.Der5,A,vext,wext,nphase,x,p,n);
  A1 = lpmjacp(x,p,n);   							%jacobianp
  temp = (eye(nphase)-A)\A1;							%temp=(I-A)^{INV}*J1
  s1=[1;0];s2=[0;1];	
  AA=zeros(nphase,nphase,n);
  wwt(:,:,n)=eye(nphase);
  x1=x;
  xit=zeros(nphase,n);xit(:,1)=x1;
  AA(:,:,1)=lpmjac(x1,p,1);
   for m=2:n
    x1=feval(lpmds.func,0,x1,p{:});
    xit(:,m)=x1;
    AA(:,:,m)=lpmjac(x1,p,1);
   end%define standard vectors  
  
  test1 = lphesspvect(xit,p,vext,AA,n)*s1; 						% A1(q,s1) 
  test1 = test1 +  multilinear2(lpmds.func,vext,temp*s1,x,p,n,hessIncrement); 	% +B(q,temp*s1)
  gamma1= wext'*test1;
  test2 = lphesspvect(xit,p,vext,AA,n)*s2; 						% A1(q,s2) 
  test2 = test2 +  multilinear2(lpmds.func,vext,temp*s2,x,p,n,hessIncrement); 	% +B(q,temp*s2)
  gamma2= wext'*test2;
  s1 = -[gamma1;gamma2]/(gamma1^2 + gamma2^2);					% new orthogonal basis
  s2 = [-gamma2;gamma1];
  h200 = (eye(nphase)-A)\(multilinear2(lpmds.func,vext,vext,x,p,n,hessIncrement));
  Abor = [A+eye(nphase) vext ; wext' 0];
  hh110 = Abor\[(gamma1*test1 + gamma2*test2)/(gamma1^2 + gamma2^2)-vext ; 0];
  hh101 = Abor\[(gamma2*test1 - gamma1*test2) ; 0];
  hh110 = hh110(1:nphase);hh101 = hh101(1:nphase); 		
%h110 = hh110 +delta1*hh101; h101 = delta2*hh101;
%
%Computation of B_1 and C_1 vectors, symbolic derivatives have to be redefined
%since they are fixed with parameters. When numerically differentiating we scale
%s1 and s2 to norm 1.
%temp1 = B_1(q,q,s1); temp3 = C_1(q,q,q,s1) + 3 B_1(q,h200,s1);
%temp2 = B_1(q,q,s2); temp4 = C_1(q,q,q,s2) + 3 B_1(q,h200,s2);
%---------------------------------------------
%wrt to s1
  p1 =p0;p1(ap) = p1(ap) + cds.options.Increment*s1/norm(s1);p1=n2c(p1);
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p1,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p1,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p1,n);
  end
  temp1 = multilinear2(lpmds.func,vext,vext,x,p1,n,hessIncrement);
  temp3 = multilinear3(lpmds.func,vext,vext,vext,x,p1,n,ten3Increment);
  temp3 = temp3 + 3.0*multilinear2(lpmds.func,vext,h200,x,p1,n,hessIncrement);
  p1 =p0;p1(ap) = p1(ap) - cds.options.Increment*s1/norm(s1);p1=n2c(p1);
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p1,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p1,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p1,n);
  end
  temp1 = temp1 - multilinear2(lpmds.func,vext,vext,x,p1,n,hessIncrement);
  temp3 = temp3 - multilinear3(lpmds.func,vext,vext,vext,x,p1,n,ten3Increment);
  temp3 = temp3 - 3.0*multilinear2(lpmds.func,vext,h200,x,p1,n,hessIncrement);
  temp1 = temp1*norm(s1)/(2.0*cds.options.Increment);
  temp3 = temp3*norm(s1)/(2.0*cds.options.Increment);
%wrt to s2
  p1 =p0;p1(ap) = p1(ap) + cds.options.Increment*s2/norm(s2);p1=n2c(p1);
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p1,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p1,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p1,n);
  end
  temp2 = multilinear2(lpmds.func,vext,vext,x,p1,n,hessIncrement);
  temp4 = multilinear3(lpmds.func,vext,vext,vext,x,p1,n,ten3Increment);
  temp4 = temp4 + 3.0*multilinear2(lpmds.func,vext,h200,x,p1,n,hessIncrement);
  p1 =p0;p1(ap) = p1(ap) - cds.options.Increment*s2/norm(s2);p1=n2c(p1);
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p1,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p1,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p1,n);
  end
  temp2 = temp2 - multilinear2(lpmds.func,vext,vext,x,p1,n,hessIncrement);
  temp4 = temp4 - multilinear3(lpmds.func,vext,vext,vext,x,p1,n,ten3Increment);
  temp4 = temp4 - 3.0*multilinear2(lpmds.func,vext,h200,x,p1,n,hessIncrement);
  temp2 = temp2*norm(s2)/(2.0*cds.options.Increment);
  temp4 = temp4*norm(s2)/(2.0*cds.options.Increment);;

%wrt to original parameter
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p1,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p1,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p1,n);
  end
%--------------------------------------------
%Continue
  test1 = lphesspvect(xit,p,h200,AA,n)*s1; 							%  A1(h200,s1)
  test1 = test1 + 2*multilinear2(lpmds.func,vext,hh110,x,p,n,hessIncrement);		%+2B(q,hh110)
  test1 = test1 +   multilinear2(lpmds.func,h200,temp*s1,x,p,n,hessIncrement);		%+ B(h200,h010)
  test1 = test1 +   multilinear3(lpmds.func,vext,vext,temp*s1,x,p,n,ten3Increment);	%+ C(q,q,h010)
  test1 = test1 +   temp1;								% see above for temp1
  hh210 = (A-eye(nphase))\(2*h200-test1);
  
  test2 = lphesspvect(xit,p,h200,AA,n)*s2; 							%  A1(h200,s2)
  test2 = test2 + 2*multilinear2(lpmds.func,vext,hh101,x,p,n,hessIncrement);		%+2B(q,hh101)
  test2 = test2 +   multilinear2(lpmds.func,h200,temp*s2,x,p,n,hessIncrement);		%+ B(h200,h001)
  test2 = test2 +   multilinear3(lpmds.func,vext,temp*s2,vext,x,p,n,ten3Increment);	%+ C(q,q,h001)
  test2 = test2 +   temp2;								% see above for temp2
  hh201 = (eye(nphase)-A)\test2;
%h210 = (A-I)\(2h200-test1-delta1*test2) = hh210 + delta1*hh201 
%h201 = (A-I)\(-delta2*test2) = delta2*hh201
  RHS3 = multilinear3(lpmds.func,vext,vext,vext,x,p,n,ten3Increment);			%   C(q,q,q)
  RHS3 = RHS3 + 3.0*multilinear2(lpmds.func,vext,h200,x,p,n,hessIncrement);   		% +3B(q,h200)
  a = wext'*RHS3/6.0;
  h300 =  Abor\[6.0*a*vext - RHS3; 0];h300 = h300(1:nphase);
%----
  test3 = lphesspvect(xit,p,h300,AA,n)*s1; 							%  A1(h300,s1)
  test3 = test3 + multilinear4(lpmds.func,vext,vext,vext,temp*s1,x,p,n,ten4Increment);	%+ D(q,q,q,h010)
  test3 = test3 + 3.0*multilinear3(lpmds.func,vext,vext,hh110,x,p,n,ten3Increment);	%+3C(q,q,hh110)
  test3 = test3 + 3.0*multilinear3(lpmds.func,vext,h200,temp*s1,x,p,n,ten3Increment);	%+3C(q,h200,h010)
  test3 = test3 + 3.0*multilinear2(lpmds.func,h200,hh110,x,p,n,hessIncrement);		%+3B(h200,hh110)
  test3 = test3 + multilinear2(lpmds.func,h300,temp*s1,x,p,n,hessIncrement);		%+ B(h300,h010)
  test3 = test3 + 3.0*multilinear2(lpmds.func,vext,hh210,x,p,n,hessIncrement);		%+3B(q,hh210)
  test3 = test3 + temp3;								% see above for temp3
  z1 = wext'*(test3);
  test4 = lphesspvect(xit,p,h300,AA,n)*s2; 							%  A1(h300,s2)
  test4 = test4 + multilinear4(lpmds.func,vext,vext,vext,temp*s2,x,p,n,ten4Increment);	%+ D(q,q,q,h001)
  test4 = test4 + 3.0*multilinear3(lpmds.func,vext,vext,hh101,x,p,n,ten3Increment);	%+3C(q,q,hh101)
  test4 = test4 + 3.0*multilinear3(lpmds.func,vext,h200,temp*s2,x,p,n,ten3Increment);	%+3C(q,h200,h001)
  test4 = test4 + 3.0*multilinear2(lpmds.func,h200,hh101,x,p,n,hessIncrement);		%+3B(h200,hh101)
  test4 = test4 + multilinear2(lpmds.func,h300,temp*s2,x,p,n,hessIncrement);		%+ B(h300,h001)
  test4 = test4 + 3.0*multilinear2(lpmds.func,vext,hh201,x,p,n,hessIncrement);  	%+3B(q,hh201)
  test4 = test4 + temp4;								% see above for temp4
  z2 = wext'*test4;
%----------------------------------------------------
%Now we can definge v10,v01 and all hx01, x=0,1,2,3 vectors.
  v10 = s1 - s2*z1/z2;
  v01 = 6*s2/z2;
  h001 = 6*temp*s2/z2;h101 = 6*hh101/z2;h201 = 6*hh201/z2;
  h301 = -Abor\[6*vext+6*test4/z2; 0];h301 = h301(1:nphase);   
%-------------------------------------------------------------------------------
%derivatives wrt to v01;
%ttemp0 = (f1+f2-2*f0)/h = J_2(v01,v01) 					needed for z1 in paper.
%ttemp1 = 2B_1(q,h001,v01)+ A_2(q,v01,v01);					needed for z2 in paper.
%ttemp2 = 2C_1(q,q,h001,v01) + 2B_1(h001,h200,v01) 				from (5.5)
%	 + 4B_1(h101,q,v01)+A_2(h200,v01,v01)
%ttemp3 =  B_2(q,q,v01,v01)							from (5.5)
%ttemp4 = 2D_1(q,q,q,h001,v01)+6C_1(q,q,h101,v01)+6C_1(q,h200,h001,v01)		from (5.6)
%	+6B_1(h201,q,v01)+6B_1(h200,h101,v01)+2B_1(h300,h001,v01)+A_2(h300,v01,v01)
%ttemp5 = C_2(q,q,q,v01,v01) + 3B_2(h200,q,v01,v01) 				from (5.6)
%-------------------------------------------------------------------------------
  p1 =p0;p1(ap) = p1(ap) + cds.options.Increment*v01/norm(v01);p1=n2c(p1);
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p1,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p1,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p1,n);
  end
  f1 = x;for i=1:n; f1 = feval(lpmds.func, 0, f1, p1{:}); end;
  ttemp0 = f1;
  ttemp1 = lphesspvect(xit,p1,vext,AA,n)*v01;
  ttemp1 = ttemp1 + 2.0*multilinear2(lpmds.func,vext,h001,x,p1,n,hessIncrement);
  ttemp2 = 2.0*multilinear3(lpmds.func,vext,vext,h001,x,p1,n,ten3Increment);
  ttemp2 = ttemp2 + 2.0*multilinear2(lpmds.func,h001,h200,x,p1,n,hessIncrement);
  ttemp2 = ttemp2 + 4.0*multilinear2(lpmds.func,h101,vext,x,p1,n,hessIncrement);    
  ttemp2 = ttemp2 + lphesspvect(xit,p1,h200,AA,n)*v01;
  ttemp3 = multilinear2(lpmds.func,vext,vext,x,p1,n,hessIncrement);
  ttemp4 = 2.0*multilinear4(lpmds.func,vext,vext,vext,h001,x,p1,n,ten4Increment);
  ttemp4 = ttemp4 + 6.0*multilinear3(lpmds.func,vext,vext,h101,x,p1,n,ten3Increment);
  ttemp4 = ttemp4 + 6.0*multilinear3(lpmds.func,vext,h200,h001,x,p1,n,ten3Increment);
  ttemp4 = ttemp4 + 6.0*multilinear2(lpmds.func,vext,h201,x,p1,n,hessIncrement);
  ttemp4 = ttemp4 + 6.0*multilinear2(lpmds.func,h101,h200,x,p1,n,hessIncrement);
  ttemp4 = ttemp4 + 2.0*multilinear2(lpmds.func,h001,h300,x,p1,n,hessIncrement);  
  ttemp4 = ttemp4 + lphesspvect(xit,p1,h300,AA,n)*v01;
  ttemp5 = multilinear3(lpmds.func,vext,vext,vext,x,p1,n,ten3Increment);
  ttemp5 = ttemp5 + 3.0*multilinear2(lpmds.func,h200,vext,x,p1,n,hessIncrement);   
%--------------------------------------------
  p1 =p0;p1(ap) = p1(ap) - cds.options.Increment*v01/norm(v01);p1=n2c(p1);
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p1,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p1,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p1,n);
  end
  f2 = x;for i=1:n; f2 = feval(lpmds.func, 0, f2, p1{:}); end
  ttemp0 = ttemp0 + f2;
  ttemp1 = ttemp1 - lphesspvect(xit,p1,vext,AA,n)*v01;
  ttemp1 = ttemp1 - 2.0*multilinear2(lpmds.func,vext,h001,x,p1,n,hessIncrement);
  ttemp2 = ttemp2 - 2.0*multilinear3(lpmds.func,vext,vext,h001,x,p1,n,ten3Increment);
  ttemp2 = ttemp2 - 2.0*multilinear2(lpmds.func,h001,h200,x,p1,n,hessIncrement);
  ttemp2 = ttemp2 - 4.0*multilinear2(lpmds.func,h101,vext,x,p1,n,hessIncrement);    
  ttemp2 = ttemp2 - lphesspvect(xit,p1,h200,AA,n)*v01;
  ttemp3 = ttemp3 + multilinear2(lpmds.func,vext,vext,x,p1,n,hessIncrement);
  ttemp4 = ttemp4 - 2.0*multilinear4(lpmds.func,vext,vext,vext,h001,x,p1,n,ten4Increment);
  ttemp4 = ttemp4 - 6.0*multilinear3(lpmds.func,vext,vext,h101,x,p1,n,ten3Increment);
  ttemp4 = ttemp4 - 6.0*multilinear3(lpmds.func,vext,h200,h001,x,p1,n,ten3Increment);
  ttemp4 = ttemp4 - 6.0*multilinear2(lpmds.func,vext,h201,x,p1,n,hessIncrement);
  ttemp4 = ttemp4 - 6.0*multilinear2(lpmds.func,h101,h200,x,p1,n,hessIncrement);
  ttemp4 = ttemp4 - 2.0*multilinear2(lpmds.func,h001,h300,x,p1,n,hessIncrement);  
  ttemp4 = ttemp4 - lphesspvect(xit,p1,h300,AA,n)*v01;  
  ttemp5 = ttemp5 + multilinear3(lpmds.func,vext,vext,vext,x,p1,n,ten3Increment);
  ttemp5 = ttemp5 + 3.0*multilinear2(lpmds.func,vext,h200,x,p1,n,hessIncrement);   
%--------------------------------------------
%change derivatives wrt to original parameter
%for the 2nd order derivatives(ttempx, x=0,3,5) the midpoint has to be calculated as well.
  if (cds.options.SymDerivative >=3)
    T1global=tens1(lpmds.func,lpmds.Jacobian,x,p,n);
    T2global=tens2(lpmds.func,lpmds.Hessians,x,p,n);
    T3global=tens3(lpmds.func,lpmds.Der3,x,p,n);
  end
  f0 = x;for i=1:n; f0 = feval(lpmds.func, 0, f0, p{:}); end
  ttemp0 = norm(v01)^2*(ttemp0 - 2.0*f0)/(cds.options.Increment^2);
  ttemp1 = norm(v01)*(ttemp1)/(2.0*cds.options.Increment);
  ttemp2 = norm(v01)*(ttemp2)/(2.0*cds.options.Increment);
  ttemp3 = ttemp3 - 2.0*multilinear2(lpmds.func,vext,vext,x,p,n,hessIncrement);
  ttemp3 = norm(v01)^2*(ttemp3)/(cds.options.Increment^2);
  ttemp4 = norm(v01)*(ttemp4)/(2.0*cds.options.Increment); 
  ttemp5 = ttemp5 - 2.0*multilinear3(lpmds.func,vext,vext,vext,x,p,n,ten3Increment);
  ttemp5 = ttemp5 - 6.0*multilinear2(lpmds.func,vext,h200,x,p,n,hessIncrement);   
  ttemp5 = norm(v01)^2*(ttemp5)/(cds.options.Increment^2); 
%--------------------------------------------
%Continue
%test5 = z1, test6 = z2 (according to the paper, not the z1, z2 from above.)
  test5 = ttemp0;								%   J_2(v01,v01)
  test5 = test5 +2*lphesspvect(xit,p,h001,AA,n)*v01; 				% +2A1(h001,v01)
  test5 = test5 +  multilinear2(lpmds.func,h001,h001,x,p,n,hessIncrement);	% + B(h001,h001)
  test6 = ttemp1;						    		% + A_2(q,v01,v01)+2B_1(q,h001,v01)
  test6 = test6 +2*lphesspvect(xit,p,h101,AA,n)*v01; 				% +2A_1(h101,v01)
  test6 = test6 +  multilinear3(lpmds.func,h001,h001,vext,x,p,n,ten3Increment);	% + C(q,h001,h001)
  test6 = test6 +2*multilinear2(lpmds.func,h101,h001,x,p,n,hessIncrement);	% +2B(h101,h001)
%--------------------------------------------
% solving at order 102; h002 = hh002 + delta3(I-A)\A1*s2; hh102 = hh102 + delta3*hh101 
  temp10= test6 + multilinear2(lpmds.func,vext,(eye(nphase)-A)\test5,x,p,n,hessIncrement);
  z3 = wext'*temp10;
  hh002 = (eye(nphase)-A)\(A1*(z3*s1)+test5);
  temp11= test6 + lphesspvect(xit,p,vext,AA,n)*(z3*s1);
  temp11= temp11 + multilinear2(lpmds.func,vext,hh002,x,p,n,hessIncrement);
  hh102 = Abor\[-temp11 ;0];hh102 = hh102(1:nphase);
%order 202
  test7 = ttemp2+ttemp3;								% see above for definition
  test7 = test7 + 2*lphesspvect(xit,p,h201,AA,n)*v01; 					%+2A1(h201,v01)
  test7 = test7 + multilinear4(lpmds.func,vext,vext,h001,h001,x,p,n,ten4Increment);	%+ D(q,q,h001,h001)
  test7 = test7 + 4.0*multilinear3(lpmds.func,vext,h101,h001,x,p,n,ten3Increment);	%+4C(q,h101,h001)
  test7 = test7 + multilinear3(lpmds.func,h001,h001,h200,x,p,n,ten3Increment);		%+ C(h001,h001,h200)
  test7 = test7 + 2.0*multilinear2(lpmds.func,h201,h001,x,p,n,hessIncrement);		%+2B(h201,h001)
  test7 = test7 + 2.0*multilinear2(lpmds.func,h101,h101,x,p,n,hessIncrement);		%+2B(h101,h101)
  test7 = test7 + temp1*z3;								%  B_1(q,q,vv02)
  test7 = test7 + lphesspvect(xit,p,h200,AA,n)*(z3*s1); 					%+ A_1(h200,vv02)
  test7 = test7 + multilinear3(lpmds.func,vext,vext,hh002,x,p,n,ten3Increment);		%  C(q,q,hh002)
  test7 = test7 + 2.0*multilinear2(lpmds.func,vext,hh102,x,p,n,hessIncrement);		%+2B(q,hh102)
  test7 = test7 + multilinear2(lpmds.func,h200,hh002,x,p,n,hessIncrement);		%+ B(h200,hh002)
  hh202 = (eye(nphase)-A)\test7;
%order 302
  test8 = ttemp4 + ttemp5;								% see above for definition
  test8 = test8 + 2*lphesspvect(xit,p,h301,AA,n)*v01; 					%+2A1(h301,v01)
  test8 = test8 + multilinear5(lpmds.func,vext,vext,vext,h001,h001,x,p,n,ten5Increment);%+ E(q,q,q,h001,h001)
  test8 = test8 + 6.0*multilinear4(lpmds.func,vext,vext,h101,h001,x,p,n,ten4Increment);	%+6D(q,q,h101,h001)
  test8 = test8 + 3.0*multilinear4(lpmds.func,h001,h001,vext,h200,x,p,n,ten4Increment); %+3D(h001,h001,q,h200)
  test8 = test8 + 6.0*multilinear3(lpmds.func,h101,h101,vext,x,p,n,ten3Increment);	%+6C(h101,h101,q)
  test8 = test8 + 6.0*multilinear3(lpmds.func,h001,h101,h200,x,p,n,ten3Increment);	%+6C(h001,h001,h200)
  test8 = test8 + 6.0*multilinear3(lpmds.func,h001,h201,vext,x,p,n,ten3Increment);	%+6C(h001,h201,h101)
  test8 = test8 + multilinear3(lpmds.func,h001,h001,h300,x,p,n,ten3Increment);		%+ C(h001,h001,h300)
  test8 = test8 + 6.0*multilinear2(lpmds.func,h201,h101,x,p,n,hessIncrement);		%+6B(h201,h101)
  test8 = test8 + 2.0*multilinear2(lpmds.func,h301,h001,x,p,n,hessIncrement);		%+2B(h301,h001)
  test8 = test8 + multilinear4(lpmds.func,vext,vext,vext,hh002,x,p,n,ten4Increment);	%  D(q,q,q,hh002)
  test8 = test8 + 3.0*multilinear3(lpmds.func,vext,vext,hh102,x,p,n,ten3Increment);	%+3C(q,q,hh102)
  test8 = test8 + 3.0*multilinear3(lpmds.func,h200,vext,hh002,x,p,n,ten3Increment);	%+3C(h200,q,hh002)
  test8 = test8 + 3.0*multilinear2(lpmds.func,h200,hh102,x,p,n,hessIncrement);		%+3B(h200,hh102)
  test8 = test8 + multilinear2(lpmds.func,h300,hh002,x,p,n,hessIncrement);		%+ B(h300,hh002)
  test8 = test8 + temp3*z3 + z3*lphesspvect(xit,p,h300,AA,n)*s1;				% see above for definition + A1(h300,vv02)
  test8 = test8 + 3.0*multilinear2(lpmds.func,vext,hh202,x,p,n,hessIncrement);		%+3B(q,hh202)
%--------------------------------------------
  z4 = wext'*(test8)/z2;
  v02 = z3*s1 + z4*s2;
  x0=[x+eps*vext;lpmds.P0(ap)-2*c2*v01*eps^2+(-c2*v10+2*c2*c2*v02)*eps^4];	%predicted point
  clear T1global T2global T3global T4global T5global
%-----End of branch prediction-----------------
[x,p] =rearr(x0); p = n2c(p);
curvehandles = feval(cds.curve);
cds.curve_func = curvehandles{1};
cds.curve_options = curvehandles{3};
cds.curve_jacobian = curvehandles{4};
cds.curve_hessians = curvehandles{5}; 
cds.options = feval(cds.curve_options);
cds.options = contset(cds.options,'Increment',1e-5);
n=lpmds.Niterations;
jac =lpmjac(x,p,n)-eye(cds.ndim-2);
% calculate eigenvalues
V = eig(jac);
[Y,i] = min(abs(V));
% ERROR OR WARNING
RED = jac-V(i)*eye(lpmds.nphase);
lpmds.borders.v =real(null(RED));
lpmds.borders.w =real(null(RED'));
v0=[];
rmfield(cds,'options');

% ---------------------------------------------------------------
function [x,p] = rearr(x0)
% [x,p] = rearr(x0)
% Rearranges x0 into coordinates (x) and parameters (p)
global cds lpmds
nap = length(lpmds.ActiveParams);
nphase = cds.ndim-nap;
p = lpmds.P0;
p(lpmds.ActiveParams) = x0((nphase+1):end);
x = x0(1:nphase);
