C=[-1.62114638486435 -1.562 -1.443  -1.0987856 -0.27959455684736  0.62285460449110 -0.48255078907068 -1.24433960857123 -1.51139945471518 -1.59072793547249;-1.62114638486435 -1.443   -1.0987856    -0.27959455684736   0.62285460449110 -0.48255078907068  -1.24433960857123 -1.51139945471518 -1.59072793547249 -1.61409645976328];
 
p=[-0.4;1.03;-0.1;0];ap=[2];%p=[a,b,r] 
opt=contset;
opt=contset(opt,'MaxNumpoints',35);
opt=contset(opt,'Singularities',1);
opt=contset(opt,'MinStepsize',0.001);
opt=contset(opt,'Backward',1);
opt = contset(opt,'AutDerivative',1);
[x0,v0]=init_Hom_Hom(@Ghmap,C, p, ap,1);
[xhom,vhom,shom,hhom,fhom]=cont(@homoclinic,x0,[],opt);
cpl(xhom,vhom,shom,[23 11])
