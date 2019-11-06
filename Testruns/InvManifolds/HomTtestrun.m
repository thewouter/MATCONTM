global homds xhom shom

p=[-0.4;1.03;-0.1;0];
ap=[1 2];
x=xhom(1:end-1,shom(2).index);
p2=p;p2(homds.ActiveParams)=xhom(end,shom(2).index);
nu=homds.nu;
ns=homds.ns;
nphase=homds.nphase;

opt=contset(opt,'MaxNumpoints',10);
opt=contset(opt,'Singularities',0);
opt=contset(opt,'Backward',0);
opt=contset(opt,'AutDerivative',1);

[x0,v0]=init_HomT_HomT(@Ghmap,x,nphase,nu,ns, p2, ap,1);
[xhomT,vhomT,shomT,hhomT,fhomT]=cont(@homoclinicT,x0,[],opt);
cpl(xhomT,vhomT,shomT,[24 23])

% opt=contset(opt,'Backward',1);
% [xhomT,vhomT,shomT,hhomT,fhomT]=cont(@homoclinicT,x0,[],opt);
% cpl(xhomT,vhomT,shomT,[24 23])
