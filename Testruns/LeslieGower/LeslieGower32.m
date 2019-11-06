disp('>> global opt fpmds cds ')
global opt fpmds cds
LeslieGower12;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt=contset(opt,'MaxNumPoints',150);
p = [20;18;0.72;0.23;0.29;0.98;0.36;0.55;0.18;0.26;0.2201;0.23;0.450625;.08];ap=13;
clc;

disp('>> global  x12 v12 s12 opt fpmds cds fpmds ')
 global  x12 v12 s12 opt fpmds cds fpmds
disp('>>>>>> flip curve <<<<<<<<<<<<<')
disp('>> x1=x12(1:4,s12(4).index);p1=p;')
x1=x12(1:4,s12(4).index);p1=p;
disp('>> p1(fpmds.ActiveParams)=x12(5,s12(4).index);')
p1(fpmds.ActiveParams)=x12(5,s12(4).index);
disp('>> opt=contset(opt,''MaxNumPoints'',1000);')
opt=contset(opt,'MaxNumPoints',1000);
disp('>> opt=contset(opt,''Backward'',1);')
opt=contset(opt,'Backward',1);
opt=contset(opt,'Singularities',1);
disp('>> [x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s12(4),0.01,1);')
[x2,v2]=init_PDm_FP2m(@LeslieGower,x1,p1,s12(4),0.01,1);
disp('>> [x32,v32,s32,h32,f32]=cont(@fixedpointmap,x2,[],opt);')
[x32,v32,s32,h32,f32]=cont(@fixedpointmap,x2,[],opt);
disp('>>cpl(x32,v32,s32,[1 5])')
cpl(x32,v32,s32,[1 5])
