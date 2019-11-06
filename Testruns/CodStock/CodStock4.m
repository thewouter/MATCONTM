disp('>> global  opt cds fpmds ')
global  opt cds fpmds
disp('>>> curve of fixed points <<< ')
disp('p=[114;0.5;0.5;0.1;1];ap=4;')
p=[114;0.5;0.5;0.1;1];ap=4;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('opt = contset(opt,''Backward'',1);')
opt = contset(opt,'Backward',1);
opt = contset(opt,'MaxNumPoints',394);
opt = contset(opt,'Singularities',1);
disp('[x0,v0]=init_FPm_FPm(@Rfish,[15.36;13.183289], p, ap,1); ')
[x0,v0]=init_FPm_FPm(@Rfish,[15.36;13.183289], p, ap,1); %PD curve
disp('[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt,1); ')
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt,1);
cpl(x1,v1,s1,[3 1])
