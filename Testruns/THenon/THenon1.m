global cds hetds vhet shet

C=[0.46661702380495,0.51950188769804 ,0.48317182408537 ,0.47311690109635 ,0.6123,0.841195,1.22990435,0.6419816,0.1347307,-0.14345697, -0.33379938281268,-0.38062126993587,-0.40424194997464,-0.41621339121235,-0.42230324914752,-0.42861702380495;0.46661702380495,0.37639405084666,0.43915841488454, 0.45696220552142, 0.2067,-0.276064,-1.3327006,-1.0930203,-0.7998431,-0.6233856,-0.49516248970159,-0.46255049612568,-0.44591635361118,-0.43743735402657,-0.43311132511221,-0.42861702380495];

p=[0.3;-1.057;-0.5;0];
ap=[2];

 opt = contset; 
 %opt=contset(opt,'FunTolerance',1e-6);%0.1
 %opt=contset(opt,'VarTolerance',1e-6);%0.01
 %opt=contset(opt,'TestTolerance',1e-4);
 


[x0,v0]=init_Het_Het(@Ghmap,C, p, ap,2);

opt=contset(opt,'MaxNumpoints',30); 
opt=contset(opt,'Singularities',1);
opt=contset(opt,'Backward',1);
opt = contset(opt,'AutDerivative',0);

opt=contset(opt,'MinStepsize',1);
[xhet,vhet,shet,hhet,fhet]=cont(@heteroclinic,x0,[],opt);
cpl(xhet,vhet,shet,[35 16])
