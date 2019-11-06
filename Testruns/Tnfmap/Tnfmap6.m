disp('>> global  opt cds fpmds');
global opt cds fpmds
disp('>> ap=1; p=[-1;1;1;1];');
 ap=1;p=[-1;1;1;1];
 disp('>> opt = contset; ');
opt = contset;
disp('>> [x0,v0]=init_FPm_FPm(@Tnfmap,[0;0], p, ap,1);');
[x0,v0]=init_FPm_FPm(@Tnfmap,[0;0], p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',300);');
opt=contset; opt=contset(opt,'MaxNumPoints',300);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
opt=contset(opt,'Backward',0);
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);
disp('>>[x6,v6,s6,h6,f6]=cont(@fixedpointmap,x0,[],opt);');
[x6,v6,s6,h6,f6]=cont(@fixedpointmap,x0,[],opt);
cpl(x6,v6,s6,[3 1])
