global hetTds hetds xhet shet

p=[0.3;-1.057;-0.5;0];
ap=[1 2];
x=xhet(1:end-1,shet(2).index);
p2=p;p2(hetds.ActiveParams)=xhet(end,shet(2).index);
nu=hetds.nu;
ns=hetds.ns;
nphase=hetds.nphase;

[x0,v0]=init_HetT_HetT(@Ghmap,x,nphase,nu,ns, p2, ap,2);

opt=contset(opt,'MaxNumpoints',70);
opt=contset(opt,'Singularities',0);
opt=contset(opt,'Backward',0);
opt = contset(opt,'AutDerivative',1);

[xhetT,vhetT,shetT,hhetT,fhetT]=cont(@heteroclinicT,x0,[],opt);
cpl(xhetT,vhetT,shetT,[36 35]),

opt=contset(opt,'Backward',1);
[xhetT,vhetT,shetT,hhetT,fhetT]=cont(@heteroclinicT,x0,[],opt);
cpl(xhetT,vhetT,shetT,[36 35])