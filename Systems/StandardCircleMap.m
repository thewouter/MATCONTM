function out = StandardCircleMap
out{1} = @init;
out{2} = @fun_eval;
out{3} = @jacobian;
out{4} = @jacobianp;
out{5} = @hessians;
out{6} = @hessiansp;
out{7} = @der3;
out{8} = @der4;
out{9} = @der5;

% --------------------------------------------------------------------------
function dydt = fun_eval(t,kmrgd,omega,KK)
dydt=[kmrgd(1) + omega - (KK/2*pi)*sin(2*pi*kmrgd(1));];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(StandardCircleMap);
y0=[0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,omega,KK)
jac=[ 1 - KK*pi^2*cos(2*pi*kmrgd(1)) ];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,omega,KK)
jacp=[ 1 , -(pi*sin(2*pi*kmrgd(1)))/2 ];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,omega,KK)
hess1=[ 2*KK*pi^3*sin(2*pi*kmrgd(1)) ];
hess(:,:,1) =hess1;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,omega,KK)
hessp1=[ 0 ];
hessp2=[ -pi^2*cos(2*pi*kmrgd(1)) ];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,omega,KK)
tens31=[ 4*KK*pi^4*cos(2*pi*kmrgd(1)) ];
tens3(:,:,1,1) =tens31;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,omega,KK)
tens41=[ -8*KK*pi^5*sin(2*pi*kmrgd(1)) ];
tens4(:,:,1,1,1) =tens41;
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,omega,KK)
tens51=[ -16*KK*pi^6*cos(2*pi*kmrgd(1)) ];
tens5(:,:,1,1,1,1) =tens51;
