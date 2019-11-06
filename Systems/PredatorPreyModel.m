function out = PredatorPreyModel
out{1} = @init;
out{2} = @fun_eval;
out{3} = @jacobian;
out{4} = @jacobianp;
out{5} = @hessians;
out{6} = @hessiansp;
out{7} = @der3;
out{8} = [];
out{9} = [];

% --------------------------------------------------------------------------
function dydt = fun_eval(t,kmrgd,a,b,d,eps)
dydt=[a*kmrgd(1)*(1-kmrgd(1)) - b*kmrgd(1)*kmrgd(2)/(1+eps*kmrgd(1));
d*kmrgd(1)*kmrgd(2)/(1+eps*kmrgd(1));];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(PredatorPreyModel);
y0=[0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,a,b,d,eps)
jac=[ (b*eps*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^2 - a*(kmrgd(1) - 1) - (b*kmrgd(2))/(eps*kmrgd(1) + 1) - a*kmrgd(1) , -(b*kmrgd(1))/(eps*kmrgd(1) + 1) ; (d*kmrgd(2))/(eps*kmrgd(1) + 1) - (d*eps*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^2 , (d*kmrgd(1))/(eps*kmrgd(1) + 1) ];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,a,b,d,eps)
jacp=[ -kmrgd(1)*(kmrgd(1) - 1) , -(kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1) , 0 , (b*kmrgd(1)^2*kmrgd(2))/(eps*kmrgd(1) + 1)^2 ; 0 , 0 , (kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1) , -(d*kmrgd(1)^2*kmrgd(2))/(eps*kmrgd(1) + 1)^2 ];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,a,b,d,eps)
hess1=[ (2*b*eps*kmrgd(2))/(eps*kmrgd(1) + 1)^2 - 2*a - (2*b*eps^2*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^3 , (b*eps*kmrgd(1))/(eps*kmrgd(1) + 1)^2 - b/(eps*kmrgd(1) + 1) ; (2*d*eps^2*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^3 - (2*d*eps*kmrgd(2))/(eps*kmrgd(1) + 1)^2 , d/(eps*kmrgd(1) + 1) - (d*eps*kmrgd(1))/(eps*kmrgd(1) + 1)^2 ];
hess2=[ (b*eps*kmrgd(1))/(eps*kmrgd(1) + 1)^2 - b/(eps*kmrgd(1) + 1) , 0 ; d/(eps*kmrgd(1) + 1) - (d*eps*kmrgd(1))/(eps*kmrgd(1) + 1)^2 , 0 ];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,a,b,d,eps)
hessp1=[ 1 - 2*kmrgd(1) , 0 ; 0 , 0 ];
hessp2=[ (eps*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^2 - kmrgd(2)/(eps*kmrgd(1) + 1) , -kmrgd(1)/(eps*kmrgd(1) + 1) ; 0 , 0 ];
hessp3=[ 0 , 0 ; kmrgd(2)/(eps*kmrgd(1) + 1) - (eps*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^2 , kmrgd(1)/(eps*kmrgd(1) + 1) ];
hessp4=[ (2*b*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^2 - (2*b*eps*kmrgd(1)^2*kmrgd(2))/(eps*kmrgd(1) + 1)^3 , (b*kmrgd(1)^2)/(eps*kmrgd(1) + 1)^2 ; (2*d*eps*kmrgd(1)^2*kmrgd(2))/(eps*kmrgd(1) + 1)^3 - (2*d*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^2 , -(d*kmrgd(1)^2)/(eps*kmrgd(1) + 1)^2 ];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
hessp(:,:,4) =hessp4;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,a,b,d,eps)
tens31=[ (6*b*eps^3*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^4 - (6*b*eps^2*kmrgd(2))/(eps*kmrgd(1) + 1)^3 , (2*b*eps)/(eps*kmrgd(1) + 1)^2 - (2*b*eps^2*kmrgd(1))/(eps*kmrgd(1) + 1)^3 ; (6*d*eps^2*kmrgd(2))/(eps*kmrgd(1) + 1)^3 - (6*d*eps^3*kmrgd(1)*kmrgd(2))/(eps*kmrgd(1) + 1)^4 , (2*d*eps^2*kmrgd(1))/(eps*kmrgd(1) + 1)^3 - (2*d*eps)/(eps*kmrgd(1) + 1)^2 ];
tens32=[ (2*b*eps)/(eps*kmrgd(1) + 1)^2 - (2*b*eps^2*kmrgd(1))/(eps*kmrgd(1) + 1)^3 , 0 ; (2*d*eps^2*kmrgd(1))/(eps*kmrgd(1) + 1)^3 - (2*d*eps)/(eps*kmrgd(1) + 1)^2 , 0 ];
tens33=[ (2*b*eps)/(eps*kmrgd(1) + 1)^2 - (2*b*eps^2*kmrgd(1))/(eps*kmrgd(1) + 1)^3 , 0 ; (2*d*eps^2*kmrgd(1))/(eps*kmrgd(1) + 1)^3 - (2*d*eps)/(eps*kmrgd(1) + 1)^2 , 0 ];
tens34=[ 0 , 0 ; 0 , 0 ];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,2,1) =tens33;
tens3(:,:,2,2) =tens34;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,a,b,d,eps)
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,a,b,d,eps)
