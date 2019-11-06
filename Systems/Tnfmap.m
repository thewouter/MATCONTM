function out = Tnf
out{1} = @init;
out{2} = @fun_eval;
out{3} = @jacobian;
out{4} = @jacobianp;
out{5} = @hessians;
out{6} = @hessiansp;
out{7} = @der3;
out{8} = @der4;
out{9} = @der5;
out{10}= @userf1;
out{11}= @userf2;
% --------------------------------------------------------------------------
function dydt = fun_eval(t,kmrgd,beta1,beta2,CC,DD)
dydt=[-kmrgd(1)+kmrgd(2);;
beta1*kmrgd(1)+(-1+beta2)*kmrgd(2)+CC*kmrgd(1)^3+DD*kmrgd(1)^2*kmrgd(2);;];

% --------------------------------------------------------------------------
function [tspan,y0,options] = init
y0=[0,0];
options = odeset('Jacobian',handles(3),'JacobianP',handles(4),'Hessians',handles(5),'HessiansP',handles(6));
handles = feval(Tnf);
tspan = [0 10];

% --------------------------------------------------------------------------
function jac = jacobian(t,kmrgd,beta1,beta2,CC,DD)
jac=[[-1,1];[beta1+3*CC*kmrgd(1)^2+2*DD*kmrgd(1)*kmrgd(2),-1+beta2+DD*kmrgd(1)^2]];
% --------------------------------------------------------------------------
function jacp = jacobianp(t,kmrgd,beta1,beta2,CC,DD)
jacp=[[0,0,0,0];[kmrgd(1),kmrgd(2),kmrgd(1)^3,kmrgd(1)^2*kmrgd(2)]];
% --------------------------------------------------------------------------
function hess = hessians(t,kmrgd,beta1,beta2,CC,DD)
hess1=[[0,0];[6*CC*kmrgd(1)+2*DD*kmrgd(2),2*DD*kmrgd(1)]];
hess2=[[0,0];[2*DD*kmrgd(1),0]];
hess(:,:,1) =hess1;
hess(:,:,2) =hess2;
% --------------------------------------------------------------------------
function hessp = hessiansp(t,kmrgd,beta1,beta2,CC,DD)
hessp1=[[0,0];[1,0]];
hessp2=[[0,0];[0,1]];
hessp3=[[0,0];[3*kmrgd(1)^2,0]];
hessp4=[[0,0];[2*kmrgd(1)*kmrgd(2),kmrgd(1)^2]];
hessp(:,:,1) =hessp1;
hessp(:,:,2) =hessp2;
hessp(:,:,3) =hessp3;
hessp(:,:,4) =hessp4;
%---------------------------------------------------------------------------
function tens3  = der3(t,kmrgd,beta1,beta2,CC,DD)
tens31=[[0,0];[6*CC,2*DD]];
tens32=[[0,0];[2*DD,0]];
tens33=[[0,0];[2*DD,0]];
tens34=[[0,0];[0,0]];
tens3(:,:,1,1) =tens31;
tens3(:,:,1,2) =tens32;
tens3(:,:,2,1) =tens33;
tens3(:,:,2,2) =tens34;
%---------------------------------------------------------------------------
function tens4  = der4(t,kmrgd,beta1,beta2,CC,DD)
%---------------------------------------------------------------------------
function tens5  = der5(t,kmrgd,beta1,beta2,CC,DD)
%---------------------------------------------------------------------------    
function userfun1=userf1(t,kmrgd,beta1,beta2,CC,DD)
	userfun1=beta2-2; 
%---------------------------------------------------------------------------   
 function userfun2=userf2(t,kmrgd,beta1,beta2,CC,DD)
   userfun2=beta2-0.5;
    
