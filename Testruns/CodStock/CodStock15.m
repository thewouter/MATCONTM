global x1 v1 s1  opt cds fpmds  nsmds
F=55;p=0.5;m1=0.5;m2=0.5;b1=3;b2=2;b3=1;
p=[200;0.5;0.5;0.5;1;2;3];ap=7;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt = contset(opt,'Backward',1);
opt = contset(opt,'MaxNumPoints',900);
opt = contset(opt,'Singularities',1);
disp('>>> curve of fixed point <<< ')
[x0,v0]=init_FPm_FPm(@NAFstock,[72.8206;1.33341], p, ap,1);
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt);

clc

global  opt fpmds nsmds
xx2=x1(1:2,s1(3).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(3).index);
opt=contset(opt,'MaxNumPoints',400);
opt=contset(opt,'Singularities',1);
%opt=contset(opt,'IgnoreSingularity',[2 3 4 5 ]); 
opt = contset(opt,'Backward',0);
disp('>>> curve of NS <<< ')
[x2,v2]=init_NSm_NSm(@NAFstock,xx2,p1,[4 7],1);
opt=contset(opt,'IgnoreSingularity',[5]); 
[x31,v31,s31,h31,f31]=cont(@neimarksackermap,x2,[],opt);
cpl(x31,v31,s31,[ 4 3 ]);
opt=contset(opt,'MaxNumPoints',150);
opt = contset(opt,'Backward',1);
[x32,v32,s32,h32,f32]=cont(@neimarksackermap,x2,[],opt);
cpl(x32,v32,s32,[ 4 3 ]);