C=[-1.62114638486435 -1.562 -1.443  -1.0987856 -0.27959455684736  0.62285460449110 ...
   -0.48255078907068 -1.24433960857123 -1.51139945471518 -1.59072793547249;
   -1.62114638486435 -1.443   -1.0987856    -0.27959455684736   0.62285460449110 ...
   -0.48255078907068  -1.24433960857123 -1.51139945471518 -1.59072793547249 -1.61409645976328];
C=reshape(C,2,10);
p=[-0.4;1.03;-0.1;0;.2];ap=[2];
opt = contset;

opt=contset(opt,'MaxNumpoints',60);
opt=contset(opt,'Singularities',1);
opt=contset(opt,'Backward',1);
opt=contset(opt,'Adapt',0);
opt = contset(opt,'AutDerivative',0);
C3D=[C;zeros(1,10)];
[xhom0,vhom0]=init_Hom_Hom(@GHM_3Dtest,C3D, p, ap,1);
[xhom1,vhom1,shom1,hhom1,fhom1]=cont(@homoclinic,xhom0,[],opt);
figure
for i=1:10
     cpl(xhom1,vhom1,shom1,[35 3*(i-1)+1])
end

xhomT0=xhom1(1:end-1,shom1(2).index);p(2) = xhom1(end,shom1(2).index);
ap=[1 2];
[xhomT0,vhomT0]=init_HomT_HomT(@GHM_3Dtest,xhomT0,3,1,2,p,ap,1);
[xhomT1,vhomT1,shomT1,hhomT1,fhomT1]=cont(@homoclinicT,xhomT0,[],opt);
cpl(xhomT1,vhomT1,shomT1,[36 35])
opt=contset(opt,'Backward',0);
[xhomT2,vhomT2,shomT2,hhomT2,fhomT2]=cont(@homoclinicT,xhomT0,[],opt);
cpl(xhomT2,vhomT2,shomT2,[36 35])
