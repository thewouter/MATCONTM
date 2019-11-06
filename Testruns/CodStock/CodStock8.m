disp('>>global  opt cds fpmds ');
global  opt cds fpmds
p=[55;0.5;0.5;0.5;3;2;1];ap=7;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
opt = contset(opt,'Backward',0);
opt = contset(opt,'MaxNumPoints',500);
opt = contset(opt,'Singularities',1);
disp('>>> curve of fixed point <<< ')
disp('>> [x0,v0]=init_FPm_FPm(@NAFstock,[2.8213;1.01868], p, ap,1);');
[x0,v0]=init_FPm_FPm(@NAFstock,[2.8213;1.01868], p, ap,1);
disp('>> [x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt); ');
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt);
cpl(x1,v1,s1,[3 1])
