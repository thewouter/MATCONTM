disp('>> global opt cds fpmds');
global opt cds fpmds
disp('>> ap=2; p=[-2;0;1;1];');
ap=2; p=[-2;0;1;1];
 disp('>> opt = contset; ');
opt = contset;
disp('>> [x0,v0]=init_FPm_FPm(@Tnfmap,[0;0], p, ap,1);');
[x0,v0]=init_FPm_FPm(@Tnfmap,[0;0], p, ap,1);
disp('>> opt=contset;opt=contset(opt,''MaxNumPoints'',300);');
opt=contset; opt=contset(opt,'MaxNumPoints',300);
disp('>> opt=contset(opt,''Singularities'',1);');
opt=contset(opt,'Singularities',1);
disp('>> opt=contset(opt,''Backward'',0);');
opt=contset(opt,'Backward',0);
disp('>> opt = contset(opt,''Multipliers'',1); ');
opt = contset(opt,'Multipliers',1);

disp('>>[x3,v3,s3,h3,f3]=cont(@fixedpointmap,x0,[],opt);');
[x3,v3,s3,h3,f3]=cont(@fixedpointmap,x0,[],opt);
disp('>> cpl(x3,v3,s3,[3 1])');
cpl(x3,v3,s3,[3  1])
