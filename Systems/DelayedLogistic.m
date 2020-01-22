function out = DelayedLogistic
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
function dydt = fun_eval(t,kmrgd,R,EPS)
dydt=[R*kmrgd(1)*(1-kmrgd(2))+EPS;
kmrgd(1);];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(DelayedLogistic);
y0=[0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,R,EPS)
jac=[ -R*(kmrgd(2) - 1) , -R*kmrgd(1) ; 1 , 0 ];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,R,EPS)
jacp=[ -kmrgd(1)*(kmrgd(2) - 1) , 1 ; 0 , 0 ];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,R,EPS)
hess1=[ 0 , -R ; 0 , 0 ];
hess2=[ -R , 0 ; 0 , 0 ];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,R,EPS)
hessp1=[ 1 - kmrgd(2) , -kmrgd(1) ; 0 , 0 ];
hessp2=[ 0 , 0 ; 0 , 0 ];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,R,EPS)
tens31=[ 0 , 0 ; 0 , 0 ];
tens32=[ 0 , 0 ; 0 , 0 ];
tens33=[ 0 , 0 ; 0 , 0 ];
tens34=[ 0 , 0 ; 0 , 0 ];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,2,1) =tens33;
tens3(:,:,2,2) =tens34;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,R,EPS)
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,R,EPS)
