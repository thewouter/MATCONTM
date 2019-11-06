function out = NAFstock
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
function dydt = fun_eval(t,kmrgd,F,P,m1,m2,B1,B2,B3)
dydt=[F*exp(-B1*kmrgd(2))*kmrgd(2)+(1-m1)*exp(-B2*kmrgd(2))*kmrgd(1),;
P*exp(-B3*kmrgd(2))*kmrgd(1)+(1-m2)*kmrgd(2),;];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
handles = feval(NAFstock);
y0=[0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,F,P,m1,m2,B1,B2,B3)
jac=[[(1-m1)*exp(-B2*kmrgd(2)),-F*B1*exp(-B1*kmrgd(2))*kmrgd(2)+F*exp(-B1*kmrgd(2))-(1-m1)*B2*exp(-B2*kmrgd(2))*kmrgd(1)];[P*exp(-B3*kmrgd(2)),-P*B3*exp(-B3*kmrgd(2))*kmrgd(1)+1-m2]];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,F,P,m1,m2,B1,B2,B3)
jacp=[[exp(-B1*kmrgd(2))*kmrgd(2),0,-exp(-B2*kmrgd(2))*kmrgd(1),0,-F*exp(-B1*kmrgd(2))*kmrgd(2)^2,-(1-m1)*kmrgd(2)*exp(-B2*kmrgd(2))*kmrgd(1),0];[0,exp(-B3*kmrgd(2))*kmrgd(1),0,-kmrgd(2),0,0,-P*kmrgd(2)*exp(-B3*kmrgd(2))*kmrgd(1)]];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,F,P,m1,m2,B1,B2,B3)
hess1=[[0,-(1-m1)*B2*exp(-B2*kmrgd(2))];[0,-P*B3*exp(-B3*kmrgd(2))]];
hess2=[[-(1-m1)*B2*exp(-B2*kmrgd(2)),F*B1^2*exp(-B1*kmrgd(2))*kmrgd(2)-2*F*B1*exp(-B1*kmrgd(2))+(1-m1)*B2^2*exp(-B2*kmrgd(2))*kmrgd(1)];[-P*B3*exp(-B3*kmrgd(2)),P*B3^2*exp(-B3*kmrgd(2))*kmrgd(1)]];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,F,P,m1,m2,B1,B2,B3)
hessp1=[[0,-B1*exp(-B1*kmrgd(2))*kmrgd(2)+exp(-B1*kmrgd(2))];[0,0]];
hessp2=[[0,0];[exp(-B3*kmrgd(2)),-B3*exp(-B3*kmrgd(2))*kmrgd(1)]];
hessp3=[[-exp(-B2*kmrgd(2)),B2*exp(-B2*kmrgd(2))*kmrgd(1)];[0,0]];
hessp4=[[0,0];[0,-1]];
hessp5=[[0,-2*F*exp(-B1*kmrgd(2))*kmrgd(2)+F*B1*exp(-B1*kmrgd(2))*kmrgd(2)^2];[0,0]];
hessp6=[[-(1-m1)*kmrgd(2)*exp(-B2*kmrgd(2)),-(1-m1)*exp(-B2*kmrgd(2))*kmrgd(1)+(1-m1)*B2*kmrgd(2)*exp(-B2*kmrgd(2))*kmrgd(1)];[0,0]];
hessp7=[[0,0];[-P*kmrgd(2)*exp(-B3*kmrgd(2)),-P*exp(-B3*kmrgd(2))*kmrgd(1)+P*B3*kmrgd(2)*exp(-B3*kmrgd(2))*kmrgd(1)]];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
hessp(:,:,4) =hessp4;
hessp(:,:,5) =hessp5;
hessp(:,:,6) =hessp6;
hessp(:,:,7) =hessp7;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,F,P,m1,m2,B1,B2,B3)
tens31=[[0,0];[0,0]];
tens32=[[0,(1-m1)*B2^2*exp(-B2*kmrgd(2))];[0,P*B3^2*exp(-B3*kmrgd(2))]];
tens33=[[0,(1-m1)*B2^2*exp(-B2*kmrgd(2))];[0,P*B3^2*exp(-B3*kmrgd(2))]];
tens34=[[(1-m1)*B2^2*exp(-B2*kmrgd(2)),-F*B1^3*exp(-B1*kmrgd(2))*kmrgd(2)+3*F*B1^2*exp(-B1*kmrgd(2))-(1-m1)*B2^3*exp(-B2*kmrgd(2))*kmrgd(1)];[P*B3^2*exp(-B3*kmrgd(2)),-P*B3^3*exp(-B3*kmrgd(2))*kmrgd(1)]];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,2,1) =tens33;
tens3(:,:,2,2) =tens34;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,F,P,m1,m2,B1,B2,B3)
tens41=[[0,0];[0,0]];
tens42=[[0,0];[0,0]];
tens43=[[0,0];[0,0]];
tens44=[[0,-(1-m1)*B2^3*exp(-B2*kmrgd(2))];[0,-P*B3^3*exp(-B3*kmrgd(2))]];
tens45=[[0,0];[0,0]];
tens46=[[0,-(1-m1)*B2^3*exp(-B2*kmrgd(2))];[0,-P*B3^3*exp(-B3*kmrgd(2))]];
tens47=[[0,-(1-m1)*B2^3*exp(-B2*kmrgd(2))];[0,-P*B3^3*exp(-B3*kmrgd(2))]];
tens48=[[-(1-m1)*B2^3*exp(-B2*kmrgd(2)),F*B1^4*exp(-B1*kmrgd(2))*kmrgd(2)-4*F*B1^3*exp(-B1*kmrgd(2))+(1-m1)*B2^4*exp(-B2*kmrgd(2))*kmrgd(1)];[-P*B3^3*exp(-B3*kmrgd(2)),P*B3^4*exp(-B3*kmrgd(2))*kmrgd(1)]];
tens4(:,:,1,1,1) =tens41;
tens4(:,:,1,1,2) =tens42;
tens4(:,:,1,2,1) =tens43;
tens4(:,:,1,2,2) =tens44;
tens4(:,:,2,1,1) =tens45;
tens4(:,:,2,1,2) =tens46;
tens4(:,:,2,2,1) =tens47;
tens4(:,:,2,2,2) =tens48;
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,F,P,m1,m2,B1,B2,B3)
tens51=[[0,0];[0,0]];
tens52=[[0,0];[0,0]];
tens53=[[0,0];[0,0]];
tens54=[[0,0];[0,0]];
tens55=[[0,0];[0,0]];
tens56=[[0,0];[0,0]];
tens57=[[0,0];[0,0]];
tens58=[[0,(1-m1)*B2^4*exp(-B2*kmrgd(2))];[0,P*B3^4*exp(-B3*kmrgd(2))]];
tens59=[[0,0];[0,0]];
tens510=[[0,0];[0,0]];
tens511=[[0,0];[0,0]];
tens512=[[0,(1-m1)*B2^4*exp(-B2*kmrgd(2))];[0,P*B3^4*exp(-B3*kmrgd(2))]];
tens513=[[0,0];[0,0]];
tens514=[[0,(1-m1)*B2^4*exp(-B2*kmrgd(2))];[0,P*B3^4*exp(-B3*kmrgd(2))]];
tens515=[[0,(1-m1)*B2^4*exp(-B2*kmrgd(2))];[0,P*B3^4*exp(-B3*kmrgd(2))]];
tens516=[[(1-m1)*B2^4*exp(-B2*kmrgd(2)),-F*B1^5*exp(-B1*kmrgd(2))*kmrgd(2)+5*F*B1^4*exp(-B1*kmrgd(2))-(1-m1)*B2^5*exp(-B2*kmrgd(2))*kmrgd(1)];[P*B3^4*exp(-B3*kmrgd(2)),-P*B3^5*exp(-B3*kmrgd(2))*kmrgd(1)]];
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
