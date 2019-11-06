global hetds
C=[ 0.4666    0.4666    0.4738    0.4547    0.4862    0.4337    0.5204 ...
    0.3747    0.6122    0.2066    0.8412   -0.2761    1.2290   -1.3327 ...
    0.6419   -1.0930    0.1347   -0.7998   -0.1434   -0.6233   -0.2848 ...
   -0.5288   -0.3560   -0.4798   -0.3919   -0.4547   -0.4100   -0.4419 ...
   -0.4192   -0.4354   -0.4286   -0.4286   ];
C=reshape(C,2,16);
p=[0.3;-1.057;-0.5;0;.2];
ap=[2];
opt = contset;
 
opt=contset(opt,'MaxNumpoints',30);
opt=contset(opt,'Singularities',1);
opt=contset(opt,'Backward',1);
opt=contset(opt,'Adapt',0);
opt = contset(opt,'AutDerivative',0);
C3D=[C;zeros(1,16)];
[x0,v0]=init_Het_Het(@GHM_3Dtest,C3D, p, ap,2);
[xhet2,vhet2,shet2,hhet2,fhet2]=cont(@heteroclinic,x0,[],opt);
figure
for i=1:16
     cpl(xhet2,vhet2,shet2,[53 3*(i-1)+1])
end

opt=contset(opt,'Singularities',0);
p=[0.3;-1.057;-0.5;0;.2];
ap=[1 2];
x=xhet2(1:end-1,shet2(2).index);
p2=p;p2(hetds.ActiveParams)=xhet2(end,shet2(2).index);
nu=hetds.nu;
ns=hetds.ns;
nphase=hetds.nphase;
[x0,v0]=init_HetT_HetT(@GHM_3Dtest,x,nphase,nu,ns, p2, ap,2);
[xhetT2,vhetT2,shetT2,hhetT2,fhetT2]=cont(@heteroclinicT,x0,[],opt);
