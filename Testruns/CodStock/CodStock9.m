disp('>>> global  opt cds fpmds ')
global  opt cds fpmds
disp('>>> curve of fixed point <<< ')
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>>p=[55;0.5;0.5;0.5;3;2;1];ap=1; ')
p=[55;0.5;0.5;0.5;3;2;1];ap=1;
opt = contset(opt,'Backward',1);
opt = contset(opt,'MaxNumPoints',50);
opt = contset(opt,'Singularities',1);
disp('>>>[x0,v0]=init_FPm_FPm(@NAFstock,[2.8213;1.01868], p, ap,1);')
[x0,v0]=init_FPm_FPm(@NAFstock,[2.8213;1.01868], p, ap,1);
disp('>>> curve of fixed point <<< ')
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt);
clc
disp('>>>> NS curve   starting in NSm >>>>>>')
disp('>> global x1 v1 s1 opt fpmds nsmds')
global x1 v1 s1 opt fpmds nsmds
disp('>>>xx2=x1(1:2,s1(2).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(2).index);')
xx2=x1(1:2,s1(2).index);p1=p;p1(fpmds.ActiveParams)=x1(3,s1(2).index);
opt=contset(opt,'MaxNumPoints',100);
opt=contset(opt,'Singularities',1);
opt = contset(opt,'Backward',0);
disp('>>>[x2,v2]=init_NSm_NSm(@NAFstock,xx2,p1,[1 7],1); ')
[x2,v2]=init_NSm_NSm(@NAFstock,xx2,p1,[1 7],1);
disp('opt=contset(opt,''IgnoreSingularity'',[5]); ')
opt=contset(opt,'IgnoreSingularity',[5]); 
disp('>>> [x31,v31,s31,h31,f31]=cont(@neimarksackermap,x2,[],opt);')
[x31,v31,s31,h31,f31]=cont(@neimarksackermap,x2,[],opt);
cpl(x31,v31,s31,[ 4 3 ]);
opt=contset(opt,'MaxNumPoints',500);
% opt = contset(opt,'Backward',1);
% 
% disp('>>> [x32,v32,s32,h32,f32]=cont(@neimarksackermap,x2,[],opt);')
% [x32,v32,s32,h32,f32]=cont(@neimarksackermap,x2,[],opt);
% cpl(x31,v31,s31,[ 4 3 ]);