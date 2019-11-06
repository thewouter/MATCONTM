disp('>> global cds fpmds; ');
global opt cds fpmds
disp('>> p=[120;0.5;0.5;0.9;1];ap=1;; ');
p=[120;0.5;0.5;0.9;1];ap=1;
disp('>> opt = contset; ');
opt = contset;
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>> opt = contset(opt,''Backward'',0); ');
opt = contset(opt,'Backward',0);
opt = contset(opt,'MaxNumPoints',200);
disp('>>opt = contset(opt,''Singularities'',1); ');
opt = contset(opt,'Singularities',1);

disp('opt = contset(opt,''Singularities'',1);');
disp('>>> curve of fixed points <<< ')
disp('>> [x0,v0]=init_FPm_FPm(@Rfish,[32.28140;2.1305], p, ap,1); ');
[x0,v0]=init_FPm_FPm(@Rfish,[32.28140;2.1305], p, ap,1);
disp('>> [x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt,1); ');
[x1,v1,s1,h1,f1]=cont(@fixedpointmap,x0,[],opt,1);
disp('>> cpl(x1,v1,s1,[3 1]); ');
cpl(x1,v1,s1,[3 1]);
disp('>> opt = contset(opt,''MaxNumPoints'',1250); ');
opt = contset(opt,'MaxNumPoints',1250);
disp('>>opt = contset(opt,''Backward'',1); ');
opt = contset(opt,'Backward',1);
disp('>> [x2,v2,s2,h2,f2]=cont(@fixedpointmap,x0,[],opt,1); ');
[x2,v2,s2,h2,f2]=cont(@fixedpointmap,x0,[],opt,1);
disp('>>cpl(x2,v2,s2,[3 1]), ');
cpl(x2,v2,s2,[3 1]),


  