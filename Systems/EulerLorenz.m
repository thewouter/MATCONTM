function out = EulerLorenz
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
function dydt = fun_eval(t,kmrgd,sig,rr,bb,hh)
dydt=[kmrgd(1)+hh*sig*(kmrgd(2)-kmrgd(1));
kmrgd(2)+hh*(rr*kmrgd(1)-kmrgd(2)-kmrgd(1)*kmrgd(3));
kmrgd(3)+hh*(kmrgd(1)*kmrgd(2)-bb*kmrgd(3));];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(EulerLorenz);
y0=[0,0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,sig,rr,bb,hh)
jac=[[1 - hh*sig, hh*sig, 0]; [hh*(rr - kmrgd(3)), 1 - hh, -hh*kmrgd(1)]; [hh*kmrgd(2), hh*kmrgd(1), 1 - bb*hh]];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,sig,rr,bb,hh)
jacp=[[-hh*(kmrgd(1) - kmrgd(2)), 0, 0, -sig*(kmrgd(1) - kmrgd(2))], [0, hh*kmrgd(1), 0, rr*kmrgd(1) - kmrgd(2) - kmrgd(1)*kmrgd(3)], [0, 0, -hh*kmrgd(3), kmrgd(1)*kmrgd(2) - bb*kmrgd(3)]];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,sig,rr,bb,hh)
hess1=[[0, 0, 0], [0, 0, -hh], [0, hh, 0]];
hess2=[[0, 0, 0], [0, 0, 0], [hh, 0, 0]];
hess3=[[0, 0, 0], [-hh, 0, 0], [0, 0, 0]];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
hess(:,:,3) =hess3;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,sig,rr,bb,hh)
hessp1=[[-hh, hh, 0], [0, 0, 0], [0, 0, 0]];
hessp2=[[0, 0, 0], [hh, 0, 0], [0, 0, 0]];
hessp3=[[0, 0, 0], [0, 0, 0], [0, 0, -hh]];
hessp4=[[-sig, sig, 0], [rr - kmrgd(3), -1, -kmrgd(1)], [kmrgd(2), kmrgd(1), -bb]];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
hessp(:,:,4) =hessp4;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,sig,rr,bb,hh)
tens31=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens32=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens33=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens34=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens35=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens36=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens37=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens38=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
tens39=[[0, 0, 0], [0, 0, 0], [0, 0, 0]];
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
function tens4  = der4(t,kmrgd,sig,rr,bb,hh)
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,sig,rr,bb,hh)
