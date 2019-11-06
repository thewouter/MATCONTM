disp('>> global  opt cds fpmds ');
global  opt cds fpmds
opt=contset;
disp('>> p=[55;0.5;0.5;0.5;3;2;1];ap=5; ');
p=[55;0.5;0.5;0.5;3;2;1];ap=5;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt = contset(opt,'Backward',0);
opt = contset(opt,'MaxNumPoints',1560);
opt = contset(opt,'Singularities',1);
disp('>>> curve of fixed points <<< ')
disp('[x0,v0]=init_FPm_FPm(@NAFstock,[2.8213;1.01868], p, ap,1); ');
[x0,v0]=init_FPm_FPm(@NAFstock,[2.8213;1.01868], p, ap,1);
disp('[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt); ');
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt);
cpl(x1,v1,s1,[3 1])
