disp('>> global opt cds fpmds');
global opt cds fpmds
disp('>> ap=2; p=[-3;0;1;1];');
 ap=2;p=[-3;0;1;1];
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
disp('>>[x5,v5,s5,h5,f5]=cont(@fixedpointmap,x0,[],opt);');
[x5,v5,s5,h5,f5]=cont(@fixedpointmap,x0,[],opt);
disp('>> cpl(x5,v5,s5,[3 1])');
cpl(x5,v5,s5,[3 1])
