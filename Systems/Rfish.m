function out = Rfish
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
function dydt = fun_eval(t,kmrgd,F,P,m1,m2,Beta)
dydt=[F*exp(-Beta*kmrgd(2))*kmrgd(2)+(1-m1)*exp(-Beta*kmrgd(2))*kmrgd(1),;
P*exp(-Beta*kmrgd(2))*kmrgd(1)+(1-m2)*kmrgd(2),;];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(Rfish);
y0=[0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,F,P,m1,m2,Beta)
jac=[[(1-m1)*exp(-Beta*kmrgd(2)),-F*Beta*exp(-Beta*kmrgd(2))*kmrgd(2)+F*exp(-Beta*kmrgd(2))-(1-m1)*Beta*exp(-Beta*kmrgd(2))*kmrgd(1)];[P*exp(-Beta*kmrgd(2)),-P*Beta*exp(-Beta*kmrgd(2))*kmrgd(1)+1-m2]];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,F,P,m1,m2,Beta)
jacp=[[exp(-Beta*kmrgd(2))*kmrgd(2),0,-exp(-Beta*kmrgd(2))*kmrgd(1),0,-F*exp(-Beta*kmrgd(2))*kmrgd(2)^2-(1-m1)*exp(-Beta*kmrgd(2))*kmrgd(2)*kmrgd(1)];[0,exp(-Beta*kmrgd(2))*kmrgd(1),0,-kmrgd(2),-P*exp(-Beta*kmrgd(2))*kmrgd(2)*kmrgd(1)]];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,F,P,m1,m2,Beta)
hess1=[[0,-(1-m1)*Beta*exp(-Beta*kmrgd(2))];[0,-P*Beta*exp(-Beta*kmrgd(2))]];
hess2=[[-(1-m1)*Beta*exp(-Beta*kmrgd(2)),F*Beta^2*exp(-Beta*kmrgd(2))*kmrgd(2)-2*F*Beta*exp(-Beta*kmrgd(2))+(1-m1)*Beta^2*exp(-Beta*kmrgd(2))*kmrgd(1)];[-P*Beta*exp(-Beta*kmrgd(2)),P*Beta^2*exp(-Beta*kmrgd(2))*kmrgd(1)]];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,F,P,m1,m2,Beta)
hessp1=[[0,-Beta*exp(-Beta*kmrgd(2))*kmrgd(2)+exp(-Beta*kmrgd(2))];[0,0]];
hessp2=[[0,0];[exp(-Beta*kmrgd(2)),-Beta*exp(-Beta*kmrgd(2))*kmrgd(1)]];
hessp3=[[-exp(-Beta*kmrgd(2)),Beta*exp(-Beta*kmrgd(2))*kmrgd(1)];[0,0]];
hessp4=[[0,0];[0,-1]];
hessp5=[[-(1-m1)*exp(-Beta*kmrgd(2))*kmrgd(2),-2*F*exp(-Beta*kmrgd(2))*kmrgd(2)+F*Beta*exp(-Beta*kmrgd(2))*kmrgd(2)^2-(1-m1)*exp(-Beta*kmrgd(2))*kmrgd(1)+(1-m1)*Beta*exp(-Beta*kmrgd(2))*kmrgd(2)*kmrgd(1)];[-P*exp(-Beta*kmrgd(2))*kmrgd(2),-P*exp(-Beta*kmrgd(2))*kmrgd(1)+P*Beta*exp(-Beta*kmrgd(2))*kmrgd(2)*kmrgd(1)]];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
hessp(:,:,4) =hessp4;
hessp(:,:,5) =hessp5;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,F,P,m1,m2,Beta)
tens31=[[0,0];[0,0]];
tens32=[[0,(1-m1)*Beta^2*exp(-Beta*kmrgd(2))];[0,P*Beta^2*exp(-Beta*kmrgd(2))]];
tens33=[[0,(1-m1)*Beta^2*exp(-Beta*kmrgd(2))];[0,P*Beta^2*exp(-Beta*kmrgd(2))]];
tens34=[[(1-m1)*Beta^2*exp(-Beta*kmrgd(2)),-F*Beta^3*exp(-Beta*kmrgd(2))*kmrgd(2)+3*F*Beta^2*exp(-Beta*kmrgd(2))-(1-m1)*Beta^3*exp(-Beta*kmrgd(2))*kmrgd(1)];[P*Beta^2*exp(-Beta*kmrgd(2)),-P*Beta^3*exp(-Beta*kmrgd(2))*kmrgd(1)]];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,2,1) =tens33;
tens3(:,:,2,2) =tens34;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,F,P,m1,m2,Beta)
tens41=[[0,0];[0,0]];
tens42=[[0,0];[0,0]];
tens43=[[0,0];[0,0]];
tens44=[[0,-(1-m1)*Beta^3*exp(-Beta*kmrgd(2))];[0,-P*Beta^3*exp(-Beta*kmrgd(2))]];
tens45=[[0,0];[0,0]];
tens46=[[0,-(1-m1)*Beta^3*exp(-Beta*kmrgd(2))];[0,-P*Beta^3*exp(-Beta*kmrgd(2))]];
tens47=[[0,-(1-m1)*Beta^3*exp(-Beta*kmrgd(2))];[0,-P*Beta^3*exp(-Beta*kmrgd(2))]];
tens48=[[-(1-m1)*Beta^3*exp(-Beta*kmrgd(2)),F*Beta^4*exp(-Beta*kmrgd(2))*kmrgd(2)-4*F*Beta^3*exp(-Beta*kmrgd(2))+(1-m1)*Beta^4*exp(-Beta*kmrgd(2))*kmrgd(1)];[-P*Beta^3*exp(-Beta*kmrgd(2)),P*Beta^4*exp(-Beta*kmrgd(2))*kmrgd(1)]];
tens4(:,:,1,1,1) =tens41;
tens4(:,:,1,1,2) =tens42;
tens4(:,:,1,2,1) =tens43;
tens4(:,:,1,2,2) =tens44;
tens4(:,:,2,1,1) =tens45;
tens4(:,:,2,1,2) =tens46;
tens4(:,:,2,2,1) =tens47;
tens4(:,:,2,2,2) =tens48;
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,F,P,m1,m2,Beta)
tens51=[[0,0];[0,0]];
tens52=[[0,0];[0,0]];
tens53=[[0,0];[0,0]];
tens54=[[0,0];[0,0]];
tens55=[[0,0];[0,0]];
tens56=[[0,0];[0,0]];
tens57=[[0,0];[0,0]];
tens58=[[0,(1-m1)*Beta^4*exp(-Beta*kmrgd(2))];[0,P*Beta^4*exp(-Beta*kmrgd(2))]];
tens59=[[0,0];[0,0]];
tens510=[[0,0];[0,0]];
tens511=[[0,0];[0,0]];
tens512=[[0,(1-m1)*Beta^4*exp(-Beta*kmrgd(2))];[0,P*Beta^4*exp(-Beta*kmrgd(2))]];
tens513=[[0,0];[0,0]];
tens514=[[0,(1-m1)*Beta^4*exp(-Beta*kmrgd(2))];[0,P*Beta^4*exp(-Beta*kmrgd(2))]];
tens515=[[0,(1-m1)*Beta^4*exp(-Beta*kmrgd(2))];[0,P*Beta^4*exp(-Beta*kmrgd(2))]];
tens516=[[(1-m1)*Beta^4*exp(-Beta*kmrgd(2)),-F*Beta^5*exp(-Beta*kmrgd(2))*kmrgd(2)+5*F*Beta^4*exp(-Beta*kmrgd(2))-(1-m1)*Beta^5*exp(-Beta*kmrgd(2))*kmrgd(1)];[P*Beta^4*exp(-Beta*kmrgd(2)),-P*Beta^5*exp(-Beta*kmrgd(2))*kmrgd(1)]];
tens5(:,:,1,1,1,1) =tens51;
tens5(:,:,1,1,1,2) =tens52;
tens5(:,:,1,1,2,1) =tens53;
tens5(:,:,1,1,2,2) =tens54;
tens5(:,:,1,2,1,1) =tens55;
tens5(:,:,1,2,1,2) =tens56;
tens5(:,:,1,2,2,1) =tens57;
tens5(:,:,1,2,2,2) =tens58;
tens5(:,:,2,1,1,1) =tens59;
tens5(:,:,2,1,1,2) =tens510;
tens5(:,:,2,1,2,1) =tens511;
tens5(:,:,2,1,2,2) =tens512;
tens5(:,:,2,2,1,1) =tens513;
tens5(:,:,2,2,1,2) =tens514;
tens5(:,:,2,2,2,1) =tens515;
tens5(:,:,2,2,2,2) =tens516;
