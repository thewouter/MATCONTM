function out = NFR1
out{1} = @init;
out{2} = @fun_eval;
out{3} = @jacobian;
out{4} = [];
out{5} = [];
out{6} = [];
out{7} = [];
out{8} = [];
out{9} = [];

% --------------------------------------------------------------------------
function dydt = fun_eval(t,kmrgd,alpha,beta,A,B)
dydt=[kmrgd(1)+kmrgd(2);
kmrgd(2)+alpha+beta*kmrgd(2)+A*kmrgd(1)^2+B*kmrgd(1)*kmrgd(2);];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(NFR1);
y0=[0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,alpha,beta,A,B)
jac=[ 1 , 1 ; 2*A*kmrgd(1)+B*kmrgd(2) , 1+beta+B*kmrgd(1) ];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,a,b,R,S)
jacp=[ 0 , 0 , 0 , 0 ; 1 , -kmrgd(1) , kmrgd(1)*kmrgd(2) , kmrgd(2)^3 ];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,a,b,R,S)
hess1=[ 0 , 0 ; 0 , R ];
hess2=[ 0 , 0 ; R , 6*S*kmrgd(2) - 2 ];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,a,b,R,S)
hessp1=[ 0 , 0 ; 0 , 0 ];
hessp2=[ 0 , 0 ; -1 , 0 ];
hessp3=[ 0 , 0 ; kmrgd(2) , kmrgd(1) ];
hessp4=[ 0 , 0 ; 0 , 3*kmrgd(2)^2 ];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
hessp(:,:,4) =hessp4;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,a,b,R,S)
tens31=[ 0 , 0 ; 0 , 0 ];
tens32=[ 0 , 0 ; 0 , 0 ];
tens33=[ 0 , 0 ; 0 , 0 ];
tens34=[ 0 , 0 ; 0 , 6*S ];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,2,1) =tens33;
tens3(:,:,2,2) =tens34;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,a,b,R,S)
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,a,b,R,S)
