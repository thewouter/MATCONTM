function out = AdaptiveControlMap
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
function dydt = fun_eval(t,kmrgd,b,k, cc)
dydt=[kmrgd(2);
b*kmrgd(1) + k + kmrgd(3)*kmrgd(2);
kmrgd(3) - (k*kmrgd(2)/(cc+kmrgd(2)*kmrgd(2)))*(b*kmrgd(1) + k + kmrgd(3)*kmrgd(2) - 1);];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(AdaptiveControlMap);
y0=[0,0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,b,k,cc)
jac=[ 0 , 1 , 0 ; b , kmrgd(3) , kmrgd(2) ; -(b*k*kmrgd(2))/(cc + kmrgd(2)^2) , (2*k*kmrgd(2)^2*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^2 - (k*kmrgd(2)*kmrgd(3))/(cc + kmrgd(2)^2) - (k*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2) , 1 - (k*kmrgd(2)^2)/(cc + kmrgd(2)^2) ];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,b,k,cc)
jacp=[ 0 , 0 , 0 ; kmrgd(1) , 1 , 0 ; -(k*kmrgd(1)*kmrgd(2))/(cc + kmrgd(2)^2) , - (kmrgd(2)*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2) - (k*kmrgd(2))/(cc + kmrgd(2)^2) , (k*kmrgd(2)*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^2 ];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,b,k,cc)
hess1=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , (2*b*k*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 - (b*k)/(cc + kmrgd(2)^2) , 0 ];
hess2=[ 0 , 0 , 0 ; 0 , 0 , 1 ; (2*b*k*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 - (b*k)/(cc + kmrgd(2)^2) , (4*k*kmrgd(2)^2*kmrgd(3))/(cc + kmrgd(2)^2)^2 - (2*k*kmrgd(3))/(cc + kmrgd(2)^2) + (6*k*kmrgd(2)*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^2 - (8*k*kmrgd(2)^3*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^3 , (2*k*kmrgd(2)^3)/(cc + kmrgd(2)^2)^2 - (2*k*kmrgd(2))/(cc + kmrgd(2)^2) ];
hess3=[ 0 , 0 , 0 ; 0 , 1 , 0 ; 0 , (2*k*kmrgd(2)^3)/(cc + kmrgd(2)^2)^2 - (2*k*kmrgd(2))/(cc + kmrgd(2)^2) , 0 ];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
hess(:,:,3) =hess3;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,b,k,cc)
hessp1=[ 0 , 0 , 0 ; 1 , 0 , 0 ; -(k*kmrgd(2))/(cc + kmrgd(2)^2) , (2*k*kmrgd(1)*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 - (k*kmrgd(1))/(cc + kmrgd(2)^2) , 0 ];
hessp2=[ 0 , 0 , 0 ; 0 , 0 , 0 ; -(b*kmrgd(2))/(cc + kmrgd(2)^2) , (2*kmrgd(2)^2*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^2 - k/(cc + kmrgd(2)^2) - (kmrgd(2)*kmrgd(3))/(cc + kmrgd(2)^2) - (k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1)/(cc + kmrgd(2)^2) + (2*k*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 , -kmrgd(2)^2/(cc + kmrgd(2)^2) ];
hessp3=[ 0 , 0 , 0 ; 0 , 0 , 0 ; (b*k*kmrgd(2))/(cc + kmrgd(2)^2)^2 , (k*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^2 + (k*kmrgd(2)*kmrgd(3))/(cc + kmrgd(2)^2)^2 - (4*k*kmrgd(2)^2*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^3 , (k*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 ];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,b,k,cc)
tens31=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens32=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , (6*b*k*kmrgd(2))/(cc + kmrgd(2)^2)^2 - (8*b*k*kmrgd(2)^3)/(cc + kmrgd(2)^2)^3 , 0 ];
tens33=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens34=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , (6*b*k*kmrgd(2))/(cc + kmrgd(2)^2)^2 - (8*b*k*kmrgd(2)^3)/(cc + kmrgd(2)^2)^3 , 0 ];
tens35=[ 0 , 0 , 0 ; 0 , 0 , 0 ; (6*b*k*kmrgd(2))/(cc + kmrgd(2)^2)^2 - (8*b*k*kmrgd(2)^3)/(cc + kmrgd(2)^2)^3 , (6*k*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^2 - (24*k*kmrgd(2)^3*kmrgd(3))/(cc + kmrgd(2)^2)^3 + (18*k*kmrgd(2)*kmrgd(3))/(cc + kmrgd(2)^2)^2 - (48*k*kmrgd(2)^2*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^3 + (48*k*kmrgd(2)^4*(k + b*kmrgd(1) + kmrgd(2)*kmrgd(3) - 1))/(cc + kmrgd(2)^2)^4 , (10*k*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 - (2*k)/(cc + kmrgd(2)^2) - (8*k*kmrgd(2)^4)/(cc + kmrgd(2)^2)^3 ];
tens36=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , (10*k*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 - (2*k)/(cc + kmrgd(2)^2) - (8*k*kmrgd(2)^4)/(cc + kmrgd(2)^2)^3 , 0 ];
tens37=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens38=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , (10*k*kmrgd(2)^2)/(cc + kmrgd(2)^2)^2 - (2*k)/(cc + kmrgd(2)^2) - (8*k*kmrgd(2)^4)/(cc + kmrgd(2)^2)^3 , 0 ];
tens39=[ 0 , 0 , 0 ; 0 , 0 , 0 ; 0 , 0 , 0 ];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,1,3) =tens33;
tens3(:,:,2,1) =tens34;
tens3(:,:,2,2) =tens35;
tens3(:,:,2,3) =tens36;
tens3(:,:,3,1) =tens37;
tens3(:,:,3,2) =tens38;
tens3(:,:,3,3) =tens39;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,b,k,cc)
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,b,k,cc)
